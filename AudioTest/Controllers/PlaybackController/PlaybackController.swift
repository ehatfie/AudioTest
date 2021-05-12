//
//  PlaybackController.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/4/21.
//

import Foundation
import AVFoundation

enum AudioIndicatorType {
    case recordingStart
    case recordingStop
    case audioStart
    
    var fileName: String {
        switch self {
        case .recordingStart:
            return "startIndicator"
        case .recordingStop:
            return "stopIndicator"
        case .audioStart:
            return "audioStart"
        }
    }
}

class PlaybackController: NSObject {
    var engine = AVAudioEngine()
    var bufferPlayer = AVAudioPlayerNode()
    
    let startIndicatorUrl = Bundle.main.url(forResource: AudioIndicatorType.recordingStart.fileName, withExtension: "wav") // dont need
    let stopIndicatorUrl = Bundle.main.url(forResource: AudioIndicatorType.recordingStop.fileName, withExtension: "wav") // dont need
    let audioIndicatorUrl = Bundle.main.url(forResource: AudioIndicatorType.audioStart.fileName, withExtension: "wav")
    
    var startIndicatorPlayer: AVAudioPlayer? // dont need
    var stopIndicatorPlayer: AVAudioPlayer? // dont need
    var audioIndicatorPlayer: AVAudioPlayer?
    
    var receivedBufferCount = 0
    
    override init() {
        super.init()
        
        guard let startIndicatorUrl = self.startIndicatorUrl,
              let stopIndicatorUrl = self.stopIndicatorUrl,
              let audioIndicatorUrl = self.audioIndicatorUrl else {
            self.startIndicatorPlayer = nil
            self.stopIndicatorPlayer = nil
            self.audioIndicatorPlayer = nil
            return
        }
        
        let startTime = Date().timeIntervalSince1970
        AVAudioSession.setupForPlayback(activate: true)
        let sessionDif = Date().timeIntervalSince1970 - startTime
        self.startIndicatorPlayer = try? AVAudioPlayer(contentsOf: startIndicatorUrl)
        let startDif = Date().timeIntervalSince1970 - startTime - sessionDif
        self.stopIndicatorPlayer = try? AVAudioPlayer(contentsOf: stopIndicatorUrl)
        let stopDif = Date().timeIntervalSince1970 - startTime - startDif - sessionDif
        self.audioIndicatorPlayer = try? AVAudioPlayer(contentsOf: audioIndicatorUrl)
        
        // set volume??
        
        self.startIndicatorPlayer?.delegate = self
        self.stopIndicatorPlayer?.delegate = self
        self.audioIndicatorPlayer?.delegate = self
        
        print("session dif: \(sessionDif) start dif: \(startDif) stopDif: \(stopDif)")
    }
    
    func startEngine() {
        if !self.engine.isRunning {
            do {
                try self.engine.start()
            } catch let error {
                print("cant start engine e: \(error)")
            }
        }
        
    }
    
    func setupBufferPlayer() {
        guard let audioFormat = AVAudioFormat.defaultPCM() else { return }
        engine.attach(bufferPlayer)
        let mainMixer = engine.mainMixerNode
        engine.connect(bufferPlayer, to: mainMixer, format: audioFormat)
        //print("buffer channel count: \(bufferPlayer.outputFormat(forBus: 0).channelCount)")
        //try? engine.start()
    }
    
    func playAudioIndicator() {
        print("play audio indicator")
        audioIndicatorPlayer?.volume = 1.0
        audioIndicatorPlayer?.play()
    }
    
    func playBufferAudioIndicator() {
        guard let audioIndicatorUrl = self.audioIndicatorUrl,
              let audioFile = try? AVAudioFile(forReading: audioIndicatorUrl) else {
            return
        }
        
        let completion: AVAudioPlayerNodeCompletionHandler = { callbackType in
            print("data played back \(callbackType)")
        }
        
        let rate = audioFile.fileFormat.sampleRate
        let startTime = AVAudioTime(hostTime: 0, sampleTime: AVAudioFramePosition(0), atRate: rate)
        
        self.bufferPlayer.scheduleFile(audioFile, at: startTime, completionCallbackType: .dataPlayedBack, completionHandler: completion)
        self.bufferPlayer.volume = 1.0
        self.bufferPlayer.play()
    }
    
    func loadBuffers(_ buffers: [AVAudioPCMBuffer]) {
        
        self.startEngine()
        TimeTracker.shared.lap(identifier: "start engine")
        print("loading \(buffers.count) buffers")
        var index = 0
        for buffer in buffers {
            let value = index
            let completion: AVAudioPlayerNodeCompletionHandler = {[weak self] type in
                print("buffer \(value) stop; typ: \(type)")
                if value == 0 {
                    self?.audioPlaybackDidComplete()
                }
            }
            index += 1
            
            //print("time: \(tim)")
            self.bufferPlayer.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack, completionHandler: completion)
        }
        
    }
    
    func loadBuffer(_ buffer: AVAudioPCMBuffer, final: Bool) {
        var completion: AVAudioPlayerNodeCompletionHandler? = nil
        
        if final {
            completion = {[weak self] _ in
                self?.audioPlaybackDidComplete()
            }
        } else {
            completion = {[weak self] _ in
                print("buffer: \(self?.receivedBufferCount)")
            }
        }
        
        self.bufferPlayer.scheduleBuffer(buffer, at: nil, completionCallbackType: .dataPlayedBack, completionHandler: completion)
        self.receivedBufferCount += 1
    }
    
    func playBuffers() {
        // play indicator
        self.audioIndicatorPlayer?.play()
    }
    
    func audioIndicatorDidFinishPlaying() {
        print("audioIndicator Did Finish Playing")
        self.bufferPlayer.play()
    }
    
    func audioPlaybackDidComplete() {
        print("audio playback did complete")
        TimeTracker.shared.lap(identifier: "playback complete")
        TimeTracker.shared.stop()
        TimeTracker.shared.printEvents()
        self.bufferPlayer.pause()
        self.bufferPlayer.reset()
        
        AVAudioSession.setActive(false)
    }
    
    func playAnother() {
        self.startEngine()
        
        do {
            let file1 = try AVAudioFile(forReading: startIndicatorUrl!)
            let file2 = try AVAudioFile(forReading: stopIndicatorUrl!)
            
            let fileSampleRate = file2.fileFormat.sampleRate
            let scheduledTime = AVAudioTime(sampleTime: .zero, atRate: fileSampleRate)
            print("scheduledTime: \(scheduledTime)")
            //var playTime: AVAudioTime? = self.bufferPlayer.isPlaying ? nil : scheduledTime
            
            self.bufferPlayer.scheduleFile(file1, at: scheduledTime, completionCallbackType: .dataPlayedBack, completionHandler: {_ in
                print("file 1 playback")
            })
            
            self.bufferPlayer.scheduleFile(file1, at: nil, completionCallbackType: .dataPlayedBack, completionHandler: {_ in
                print("file 2 playback")
            })
            self.bufferPlayer.play()
        } catch let e {
            print("Play another error \(e)")
        }
    }
    
}

extension PlaybackController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("player did finish playing \(flag)")
        if player == audioIndicatorPlayer {
            audioIndicatorDidFinishPlaying()
        }
    }
}


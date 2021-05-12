//
//  RecordingController.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/4/21.
//

import Foundation
import AVFoundation

protocol AudioRecordingControllerDelegate: AnyObject {
    func recordingDidBegin()
    func recordingWillBegin()
    func recordingDidEnd()
    func dataAvailable(buffer: AVAudioPCMBuffer, initial: Bool, final: Bool)
}

class RecordingController: NSObject {
    weak var delegate: AudioRecordingControllerDelegate?
    
    // should this be separate?
    let recordingStartIndicator = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "startIndicator", withExtension: "wav")!)
    let recordingStopIndicator = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "stopIndicator", withExtension: "wav")!)
    
    var engine = AVAudioEngine()
    var downMixer = AVAudioMixerNode()
    
    var capturedBuffers: [AVAudioPCMBuffer] = []
    
    var maxRecordDuration: Double = 10
    var chunkDuration: Double = 2
    var nextSendTime: Double = 2
    var sentBufferCount: Int = 0
    
    var shouldStop = false
    var stopEngineCalled = false
    
    var lastBufferTime: Double?
    
    override init() {
        super.init()
        
        let startTime = Date().timeIntervalSince1970
        AVAudioSession.setupForRecording(activate: true)
        setupIndicators()
        setupEngine()
        let dif = Date().timeIntervalSince1970 - startTime
        
        print("recording controller setup time: \(dif)")
    }
    
    func setupIndicators() {
        // should we initialize them here too??
        recordingStartIndicator?.delegate = self
        recordingStopIndicator?.delegate = self
        
        recordingStartIndicator?.volume = 1.0
        recordingStopIndicator?.volume = 1.0
    }
    
    func setupRecording(completion: @escaping(Bool) -> Void = {_ in}) {
        AVAudioSession.sharedInstance().requestRecordPermission{ response in
            completion(response)
        }
    }
    
    func setupEngine() {
        let sessionCategory = AVAudioSession.sharedInstance().category
        guard sessionCategory == .playAndRecord else {
            print("session category must be playAndRecord")
            assert(true)
            return
        }
        
        let inputNode = self.engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(1024), format: inputFormat, block: mixerTapBlock)
    }
    
    func startEngine() -> Bool {
        do {
            try self.engine.start()
        } catch let error {
            print("start engine error: \(error)")
        }
        
        return self.engine.isRunning
    }
    
    func stopEngine() {
        self.stopEngineCalled = true
        let bus = 0
        self.engine.inputNode.removeTap(onBus: bus)
        if self.downMixer.engine != nil {
            self.downMixer.removeTap(onBus: bus)
        }
        self.engine.stop()
        self.reset()
        
        self.recordingStopIndicator?.play() // move?
    }
    
    func reset() {
        self.stopEngineCalled = false
        self.shouldStop = false
        self.lastBufferTime = nil
        self.sentBufferCount = 0
        self.nextSendTime = self.chunkDuration
        self.capturedBuffers = []
        AVAudioSession.setActive(false)
    }
    
    func mixerTapBlock(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) {
        guard !self.stopEngineCalled else {
            print("MTB - Stop engine called")
            return
        }
        
        self.capturedBuffers.append(buffer)
        
        let currentTime = Date().getTimestamp()
        var timeDif: Double = 0
        
        if let lastTime = lastBufferTime {
            timeDif = currentTime - lastTime
        } else {
            self.lastBufferTime = currentTime
        }
        
        let isFinal = (timeDif > self.maxRecordDuration) || self.shouldStop
        
        if isFinal {
            // emit final buffer
            // stop engine
            self.emitBuffer(final: isFinal)
            self.stopEngine()
        } else if timeDif > self.nextSendTime {
            // send buffer
            self.emitBuffer(final: false)
        }
    }
    
    // startRecordingFlow?
    func triggerRecordingStart() {
        
    }
    
    // closure??
    func startRecording() {
        AVAudioSession.setupForRecording(activate: true)
        self.recordingStartIndicator?.play()
    }
    
    func stopRecording() {
        self.shouldStop = true
    }
    
    func emitBuffer(final: Bool) {
        self.combineAndEmit(buffers: self.getBuffersToCombine(), final: final)
    }
    
    func getBuffersToCombine() -> [AVAudioPCMBuffer] {
        let buffers = self.capturedBuffers.map{$0}
        self.capturedBuffers = []
        return buffers
    }
    
    func combineAndEmit(buffers: [AVAudioPCMBuffer], final: Bool) {
        let totalLength = buffers.reduce(0, { results, buffer in
            return results + buffer.frameLength
        })
        
        guard let format = buffers.first?.format else { return }
        guard let outBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalLength)) else { return }
        
        let isInital = self.sentBufferCount == 0
        
        self.delegate?.dataAvailable(buffer: outBuffer, initial: isInital, final: final)
        if !final {
            self.sentBufferCount += 1
            self.nextSendTime = self.chunkDuration * (Double(self.sentBufferCount + 1))
        }
    }
    
    func recordingStartIndicatorDidComplete() {
        let success = startEngine()
        
        if success {
            delegate?.recordingDidBegin()
        } else {
            assertionFailure()
        }
    }
    
    func recordingStopIndicatorDidComplete() {
        delegate?.recordingDidEnd()
    }
}

extension RecordingController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == recordingStartIndicator {
            recordingStartIndicatorDidComplete()
        } else if player == recordingStopIndicator {
            recordingStopIndicatorDidComplete()
        }
    }
}

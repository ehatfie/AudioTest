//
//  AudioController+Playback.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/8/21.
//

import Foundation
import AVFoundation

extension AudioController {
    
    func playAudio() {
        print("play audio")
        
        self.setupIfNecessary()
        self.playbackController.playAudioIndicator()
    }
    
    func playBuffer() {
        self.setupIfNecessary()
        self.playbackController.playBufferAudioIndicator()
    }
    
    func setupIfNecessary() {
        AVAudioSession.setupForPlayback(activate: true)
        
        guard !self.setup else {
            return
        }
        self.setupPlayback()
    }
    
    func setupPlayback() {
        TimeTracker.shared.start()
        AVAudioSession.setupForPlayback(activate: true)
        TimeTracker.shared.lap(identifier: "AudioSession setup complete")
        playbackController.setupBufferPlayer()
        TimeTracker.shared.lap(identifier: "AudioSession setup BufferPlayer complete")
        TimeTracker.shared.stop()
        TimeTracker.shared.printEvents()
        
        self.setup = true
    }
    
    func startPlayback() {
        TimeTracker.shared.reset()
        TimeTracker.shared.start()
        setupIfNecessary()
        TimeTracker.shared.lap(identifier: "player setup")
        guard let buffers = generateBuffers() else {
            print("cant generate buffers")
            return
        }
        self.playbackController.loadBuffers(buffers) // load buffer player
        self.playbackController.playBuffers() // play audio
    }
    
    func generateBuffers(count: Int = 5) -> [AVAudioPCMBuffer]? {
        print("generate buffers")
        var returnBuffers = [AVAudioPCMBuffer]()
        let frameCapacity: AVAudioFrameCount = 2048
        
        for _ in 0 ..< count {
            if let buffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat.defaultPCM()!, frameCapacity: frameCapacity) {
                returnBuffers.append(buffer)
            }
        }

    return returnBuffers
    }
}

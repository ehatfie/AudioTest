//
//  AudioController.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/4/21.
//

import Foundation
import AVFoundation

// this one will have each player siloed
class AudioController {
    static let shared = AudioController()
    
    var setup: Bool = false
    
    let playbackController = PlaybackController()
    let recordingController = RecordingController()
    
    var startRecordingCompletion: ((Bool) -> Void)? = nil
    var stopRecordingCompletion: (() -> Void)? = nil
    
    private init() {
        self.recordingController.delegate = self
    }
    
    func setupPlaybackController() {
        
    }
    
    func startRecording(completion: @escaping (Bool) -> Void) {
        self.startRecordingCompletion = completion
        let status = AVAudioSession.sharedInstance().recordPermission
        if status != .granted {
            recordingController.setupRecording(completion: { status in
                print("recording permission status \(status)")
                self.startRecordingCompletion?(false)
                self.startRecordingCompletion = nil
            })
        } else {
            recordingController.startRecording()
        }
        
    }
    // if this outer controller was using an AVPlayerNode to handle the indicator we can pass the completion in there, smart???
    func stopRecording(completion: @escaping () -> Void) {
        self.stopRecordingCompletion = completion
        recordingController.stopRecording()
    }
}

extension AudioController: AudioRecordingControllerDelegate {
    func recordingDidBegin() {
        print("Recording did begin")
        startRecordingCompletion?(true)
        startRecordingCompletion = nil
    }
    
    func recordingWillBegin() {
        // necessary?
    }
    
    func recordingDidEnd() {
        print("recording did end")
        self.stopRecordingCompletion?()
        self.stopRecordingCompletion = nil
    }
    
    func dataAvailable(buffer: AVAudioPCMBuffer, initial: Bool, final: Bool) {
        // pass to playback controller
        self.playbackController.loadBuffer(buffer, final: final)
    }
}

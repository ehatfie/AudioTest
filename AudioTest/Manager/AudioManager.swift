//
//  AudioManager.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/8/21.
//

import Foundation

class AudioManager {
    let controller = AudioController.shared
    
    var isRecording = false
    
    func startRecording(completion: @escaping (Bool) -> Void) {
        //controller.startRecording(completion: <#T##(Bool) -> Void#>)
        DispatchQueue.main.async {
            self.controller.startRecording { status in
                print("start recording completion")
                completion(status)
            }
        }
    }
    
    func stopRecording() {
        print("AM - stopRecording")
        controller.stopRecording {
            print("stop recording completion")
        }
    }
    
    func startPlayback() {
        controller.startPlayback()
    }
    
    func playAudio() {
        controller.playAudio()
        // what do
        // generate AVAudioPCMBuffers
        // call setup playback
    }
    
    func playBuffer() {
        controller.playBuffer()
    }
}

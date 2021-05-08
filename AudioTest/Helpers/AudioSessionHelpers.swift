//
//  AudioSessionHelpers.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/4/21.
//

import Foundation
import AVFoundation

extension AVAudioSession {
    static func setupForRecording(activate: Bool) {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, options: [.allowBluetooth])
            try session.setActive(activate, options: .notifyOthersOnDeactivation)
            print("AVAudioSession.setupForRecording active: \(activate)")
        } catch let error {
          print("Error setting category PlayAndRecord ", error)
        }
    }
    
    static func setupForPlayback(activate: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.allowBluetooth])
            try session.setActive(activate, options: .notifyOthersOnDeactivation)
            print("AVAudioSession.setupForPlayback active: \(activate)")
        } catch let error {
          print("Error setting category playback ", error)
        }
    }
    
    static func setupForBackground(activate: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.allowBluetooth, .mixWithOthers])
            try session.setActive(activate, options: .notifyOthersOnDeactivation)
            print("AVAudioSession.setupForBackground active: \(activate)")
        } catch let error {
          print("Error setting category playback/background ", error)
        }
    }
    
    static func setActive(_ isActive: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(isActive, options: .notifyOthersOnDeactivation)
            print("AVAudioSession.setActive active: \(isActive)")
        } catch let error {
          print("Error setting AVAudioSession to \(isActive) ", error)
        }
    }
}

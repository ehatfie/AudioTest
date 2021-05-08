//
//  AVAudioFormat+Extensions.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/4/21.
//

import Foundation
import AVFoundation

extension AVAudioFormat {
    
    static func defaultPCM() -> AVAudioFormat? {
        return AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 441000, channels: 1, interleaved: false)
    }
}

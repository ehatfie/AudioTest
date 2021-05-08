//
//  Date+Extensions.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/4/21.
//

import Foundation

extension Date {
    /**
     TimeIntervalSince1970 in milliseconds
     */
    func getTimestamp() -> Double {
        let timeInterval = self.timeIntervalSinceReferenceDate
        let timestamp = (timeInterval * 1000)//.rounded()
        return timestamp
    }
}

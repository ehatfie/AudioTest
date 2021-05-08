//
//  TimeTracker.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/8/21.
//

import Foundation


struct TimeEvent {
    let id: String
    let time: Double
    let delta: Double
    
    init(id: String, time: Double = Date().getTimestamp(), last: Double?) {
        self.id = id
        self.time = time
        self.delta = time - (last ?? 0)
    }
}

class TimeTracker {
    static let shared = TimeTracker()
    
    var startTime: Double?
    var lastTime: Double? // lastTime
    
    var events: [TimeEvent]?
    
    func start() {
        self.reset()
        self.events = []
        
        let time = Date().getTimestamp()
        
        self.startTime = time
        self.lastTime = time
        self.lap(identifier: "start")
    }
    
    func stop() {
        self.lap(identifier: "Stop")
    }
    
    func pause() {
        self.lap(identifier: "pause")
    }
    
    func resume() {
        //??
    }
    
    func reset() {
        self.startTime = nil
        self.lastTime = nil
        self.events = nil
    }
    /**
        Add Lap
     */
    func lap(identifier: String = "") {
        let now = Date().getTimestamp()
        
        let event = TimeEvent(id: identifier, time: now, last: lastTime)
        self.lastTime = event.time
        self.events?.append(event)
        
        self.lastTime = now
    }
    
    func printEvents() {
        guard let events = self.events else {
            print("no events")
            return
        }
        
        for event in events {
            print("id: \(event.id) delta: \(event.delta)")
        }
    }
}

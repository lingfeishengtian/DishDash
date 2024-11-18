//
//  PausableTimer.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation

class PausableTimer {
    let baseTime: Int
    private var currentTime: Double
    private let tickTime: Double
    
    let callback: (Double) -> Void
    let onCompletion: () -> Void
    var timer: Timer?
    
    /// Callback runs every 0.1 seconds
    init(time: Int, tickTime: Double = 0.1, callback: @escaping (Double) -> Void, onCompletion: @escaping () -> Void) {
        self.baseTime = time
        self.currentTime = Double(time)
        self.callback = callback
        self.onCompletion = onCompletion
        self.tickTime = tickTime
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: tickTime, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.currentTime -= tickTime
            self.callback(self.currentTime)
            
            if self.currentTime <= 0 {
                self.onCompletion()
            }
        }
    }
    
    func pause() {
        timer?.invalidate()
    }
    
    func stop() {
        pause()
        currentTime = Double(baseTime)
    }
    
    func resume() {
        start()
    }
}

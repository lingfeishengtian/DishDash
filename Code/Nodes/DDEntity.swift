//
//  DDEntity.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation
import SpriteKit

class DDEntity: SKSpriteNode {
    private var internalTimer: PausableTimer?
    private var timerGuage: SKSpriteNode?
    
    private func createTimerGuage(time: Int) {
        timerGuage = SKSpriteNode(color: .red, size: CGSize(width: self.size.width, height: 5))
        timerGuage?.position = CGPoint(x: 0, y: -self.size.height / 2 - 5)
        addChild(timerGuage!)
        
//        let timerGuageWidth = self.size.width
//        self.timerGuage?.run(SKAction.resize(byWidth: -timerGuageWidth, height: 0, duration: Double(time)))
    }
    
    private func removeTimerGuage() {
        timerGuage?.removeFromParent()
    }
    
    func startTimer(withSeconds seconds: Int, completion: @escaping () -> Void) {
        timerGuage?.removeFromParent()
        createTimerGuage(time: seconds)
        internalTimer = PausableTimer(time: seconds) { tick in
            self.timerGuage?.run(SKAction.resize(toWidth: self.size.width * CGFloat(tick) / CGFloat(seconds), duration: 0.1))
        } onCompletion: {
            completion()
        }
        internalTimer?.start()
    }
    
    func pauseTimer() {
        internalTimer?.pause()
    }
    
    func resumeTimer() {
        internalTimer?.resume()
    }
    
    func stopTimer() {
        internalTimer?.stop()
        removeTimerGuage()
    }
}

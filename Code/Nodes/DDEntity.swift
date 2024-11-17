//
//  DDEntity.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation
import SpriteKit

class DDEntity: SKSpriteNode {
    private var timerGuage: SKSpriteNode?
    func createTimerGuage(time: Int) {
        timerGuage = SKSpriteNode(color: .red, size: CGSize(width: self.size.width, height: 5))
        timerGuage?.position = CGPoint(x: 0, y: -self.size.height / 2 - 5)
        addChild(timerGuage!)
        
        let timerGuageWidth = self.size.width
        self.timerGuage?.run(SKAction.resize(byWidth: -timerGuageWidth, height: 0, duration: Double(time)))
    }
    
    func removeTimerGuage() {
        timerGuage?.removeFromParent()
    }
}

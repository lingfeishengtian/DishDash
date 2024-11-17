//
//  LosingHandler.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation
import SpriteKit
import UIKit

extension GameScene {
    func showLosingScreen() {
        background = SKShapeNode(rect: self.frame)
        background.fillColor = UIColor.black.withAlphaComponent(0.75)
        background.zPosition = 10
        
        // Game Over
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        gameOverLabel.zPosition = 11
        
        // Restart button
        let restartButton = SKLabelNode(text: "Restart")
        restartButton.fontSize = 30
        restartButton.name = "RestartButton"
        restartButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 50)
        restartButton.zPosition = 11
        
        background.addChild(gameOverLabel)
        background.addChild(restartButton)
        self.addChild(background)
    }
    
    func restartGame() {
        background.removeFromParent()
        startNewCustomerTimer()
    }
    
    func removeAllFoodItemsFromScene() {
        for child in children {
            if let food = child as? Food {
                food.removeFromParent()
            }
        }
    }
    
    func loseGame() {
        draggedFood = nil
        
        stopAllCustomerTimers()
        
        cuttingTimer?.invalidate()
        cuttingTimer = nil
        
        portionTimer?.invalidate()
        portionTimer = nil
        
        removeAllFoodItemsFromScene()
        
        showLosingScreen()
    }
}

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
        let gameOverLabel = generateDefaultGameSceneLabel(
            text: "Game Over",
            fontSize: 40,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        )
        gameOverLabel.name = "gameOverLabel"
        
        // Restart button
        let restartButton = generateDefaultGameSceneLabel(
            text: "Restart",
            fontSize: 30,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY - 50)
        )
        restartButton.name = "RestartButton"
        
        gameOverLabel.zPosition = 11
        restartButton.zPosition = 11
        
        background.addChild(gameOverLabel)
        background.addChild(restartButton)
        self.addChild(background)
    }
    
    func restartGame() {
        score = 0
        scoreLabel.text = "Score: \(score)"
        currentLevel = 1
        
        changeTileMap(to: currentLevel)
        customersSinceStart = 0
        generateFoodSourcesToolbar()
        
        background.removeFromParent()
        startNewCustomerTimer()
    }
    
    func removeAllFoodItemsFromScene() {
        getAllFoodOnscreen().forEach { $0.removeFromParent() }
    }
    
    func loseGame() {
        draggedFood = nil
        
        stopAllCustomerTimers()
        
        for child in children {
            if let ddEntity = child as? DDEntity {
                ddEntity.stopTimer()
                ddEntity.removeFromParent()
            }
        }
        
        cuttingTimer?.invalidate()
        cuttingTimer = nil
        
        portionTimer?.invalidate()
        portionTimer = nil
        
        removeAllFoodItemsFromScene()
        
        showLosingScreen()
    }
}

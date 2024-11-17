//
//  GameScene+TutorialSceneControl.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation
import SpriteKit

extension GameScene : TutorialSceneControl {
    var foodCategory: FoodOrderCategory {
        .Sushi
    }
    
    func startTutorialPhase() {
        // TODO: pause all timers
        stopAllCustomerTimers()
        removeAllFoodItemsFromScene()
    }
    
    func endTutorialPhase() {
        // TODO: resume all timers
        startNewCustomerTimer()
        removeAllFoodItemsFromScene()
        
        // Show brief Congrats message
        let message = SKLabelNode(text: "Tutorial Complete!")
        message.fontSize = 50
        message.position = CGPoint(x: 0, y: 0)
        message.zPosition = 10
        addChild(message)
        
        let fadeOut = SKAction.fadeOut(withDuration: 3)
        let remove = SKAction.removeFromParent()
        message.run(.sequence([fadeOut, remove]))
    }
    
    func highlightFood(foodItem: FoodItem) {
        getAllFoodOnscreen().forEach { food in
            if let currentTutorialPhase = currentTutorialPhase {
                switch currentTutorialPhase {
                case .cook(let foodItem):
                    food.cookOverride = foodItem
                default:
                    break
                }
            }
            
            if food.foodIdentifier == foodItem {
                food.addGlow()
            }
        }
        
        for foodSourceSprite in foodSourceToolbar.children {
            if let spriteNode = foodSourceSprite as? SKSpriteNode, foodSourceSprite.name == "FoodSource\(foodItem.rawValue)" {
                spriteNode.addGlow()
            }
        }
    }
    
    private func highlightTile(at position: TilePoint) {
        let effect = SKSpriteNode(imageNamed: "TileHighlight")
        effect.position = convertTilePointToGameSceneCoords(position).applying(.init(translationX: 0, y: 10))
        effect.zPosition = 1
        effect.name = "TileHighlight"
        effect.size = sizeOfFoodSprites.applying(.init(scaleX: 0.5, y: 0.5))
        addChild(effect)
    }
    
    func highlightTile(tileType: TileType) {
        getPositionsOfTileGroup(for: tileType).forEach { position in
            highlightTile(at: position)
        }
    }
    
    func highlightCustomers(ordering foodItem: FoodItem) {
        // Does customer with foodItem in order exist?
        let customer = customersAtTables.first { $0.order == foodItem }
        if let customer = customer {
            customer.addGlow()
            
            highlightTile(at: customer.tableSittingAt!)
        } else {
            let customer = Customer(order: foodItem, timeLimit: -1, size: sizeOfFoodSprites, onPatienceRunOut: {})
            let _ = addCustomer(customer)
            customer.addGlow()
            highlightTile(at: customer.tableSittingAt!)
        }
    }
    
    func clearHighlights() {
        getAllFoodOnscreen().forEach { food in
            food.removeAllEffects()
        }
        
        for foodSourceSprite in foodSourceToolbar.children {
            if let spriteNode = foodSourceSprite as? SKSpriteNode {
                spriteNode.removeAllEffects()
            }
        }
        
        children.forEach { child in
            if child.name == "TileHighlight" {
                child.removeFromParent()
            }
        }
        
        customersAtTables.forEach { customer in
            customer.removeAllEffects()
        }
    }
}

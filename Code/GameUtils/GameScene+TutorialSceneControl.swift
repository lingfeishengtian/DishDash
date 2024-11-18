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
        currentLevel == 1 ? .Steak : .All
    }
    
    func startTutorialPhase() {
        inTutorialPhase = true
        stopAllCustomerTimers()
        removeAllFoodItemsFromScene()
    }
    
    var showTutorialIndicator: Bool {
        true
    }
    
    func endTutorialPhase() {
        inTutorialPhase = false
        startNewCustomerTimer()
        removeAllFoodItemsFromScene()
        clearHighlights()
        updateCurrentRecipeInstructions()
        
        // Show brief Congrats message
        let messageLine1 = generateDefaultGameSceneLabel(
            text: "Tutorial",
            fontSize: 50
        )
        let messageLine2 = generateDefaultGameSceneLabel(
            text: "Complete!",
            fontSize: 50,
            position: CGPoint(x: 0, y: -50)
        )
        messageLine1.zPosition = 10
        messageLine2.zPosition = 10
        
        addChild(messageLine1)
        addChild(messageLine2)
        
        let fadeOut = SKAction.fadeOut(withDuration: 3)
        let remove = SKAction.removeFromParent()
        messageLine1.run(.sequence([fadeOut, remove]))
        messageLine2.run(.sequence([fadeOut, remove]))
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
    }
    
    func highlightForTutorialPhase(nextAction: TutorialAction) {
        clearHighlights()
        switch nextAction {
        case .combine(let food1, let food2):
            if draggedFood?.foodIdentifier == food1 {
                highlightFood(foodItem: food2)
            } else {
                highlightFood(foodItem: food1)
            }
        case .action(let food, let tileType):
            if draggedFood?.foodIdentifier == food {
                highlightTile(tileType: tileType)
            } else {
                highlightFood(foodItem: food)
            }
        case .cook(let food):
            highlightFood(foodItem: food)
        case .serve(let food):
            highlightCustomers(ordering: food)
            highlightFood(foodItem: food)
        case .grabSourceToTile(let food, let tileType):
            if draggedFood?.foodIdentifier == food {
                highlightTile(tileType: tileType)
            } else {
                highlightFoodSource(foodItem: food)
            }
        case .grabSourceToFoodItem(let food1, let food2):
            if draggedFood?.foodIdentifier == food1 {
                highlightFood(foodItem: food2)
            } else {
                highlightFoodSource(foodItem: food1)
            }
        }
        
        updateCurrentRecipeInstructions()
    }
    
    func highlightFoodSource(foodItem: FoodItem) {
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

//
//  ItemPlacementManager.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation

extension GameScene {
    enum CombineItemError: Error {
        case noCombination
    }
    
    func setFoodItemDown(_ food: Food, at tilePosition: TilePoint) -> Bool {
        if !tileGroup(at: tilePosition).placeable {
            returnFoodToTouchesBegan(food)
            return false
        }
        
        if let existingFood = getFoodOnTile(tilePosition) {
            if let combinedItem = Recipe.combineIngredients(existingFood.foodIdentifier, food.foodIdentifier) {
                
                combine(incomingFood: food, existingFood: existingFood, resultingItem: combinedItem)
                
                return true
            } else {
                returnFoodToTouchesBegan(food)
                return false
            }
        }
        
        placeFoodOnTile(food, tilePosition)
        return true
    }
    
    func combine(incomingFood: Food, existingFood: Food, resultingItem: FoodItem)
    {
        /// Only fail if both are portionable. Errors relating to this should be caught before production, but should not fail in production.
#if DEBUG
        if incomingFood.portion != nil && existingFood.portion != nil {
            fatalError("Both incoming and existing food items cannot be portionable")
        }
#endif
        
        incomingFood.portionSingle()
        existingFood.portionSingle()
        
        if let incomingPortionCount = incomingFood.portion, incomingPortionCount > 0 {
            existingFood.updateFoodItem(foodItem: resultingItem)
            
            if let prevTouches = touchesBeganLocation {
                placeFoodOnTile(incomingFood, prevTouches)
            }
        } else if let existingPortionCount = existingFood.portion, existingPortionCount > 0 {
            incomingFood.updateFoodItem(foodItem: resultingItem)
            
            if let prevTouches = touchesBeganLocation {
                placeFoodOnTile(incomingFood, prevTouches)
            }
        } else {
            existingFood.updateFoodItem(foodItem: resultingItem)
            incomingFood.removeFromParent()
        }
    }
    
    func placeFoodOnMachineTile(_ food: Food, at tilePosition: TilePoint) {
        food.startCooking()
    }
    
    func placeFoodOnNonMachineTile(_ food: Food, at tilePosition: TilePoint) {
    }
    
    func eventItemPlacedOnTable(_ food: Food, at tilePosition: TilePoint) {
        for customer in customersAtTables {
            if customer.tableSittingAt == TilePoint(x: Int(tilePosition.x), y: Int(tilePosition.y)) {
                if customer.order == food.foodIdentifier {
                    customer.orderSatisfied()
                    removeCustomer(customer)
                    draggedFood?.removeFromParent()
                    incrementScore(by: 1)
                    return
                }
            }
        }
    }
    
    func placeFoodOnTrashTile(_ food: Food, at tilePosition: TilePoint) {
        food.removeFromParent()
    }
    
    func eventItemPlacedOnSink(_ food: Food, at tilePosition: TilePoint) {
        food.sinkEvent()
    }
}

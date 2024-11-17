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
    
    /// Fire tile events for food items that have already been placed
    func fireTileEvent(_ food: Food) {
        let tilePosition = position(of: food)
        let tileGroup = tileGroup(at: tilePosition)
        
        switch tileGroup {
        case TileType.machine:
            eventMachineTile(food, at: tilePosition)
        case TileType.counter:
            eventPlaceableTile(food, at: tilePosition)
        case TileType.sink:
            eventSinkTile(food, at: tilePosition)
        case TileType.table:
            eventTableTile(food, at: tilePosition)
        case TileType.trashcan:
            eventTrashTile(food, at: tilePosition)
        default:
            returnFoodToTouchesBegan(food)
        }
    }
    
    /// Returns food items to fire events on
    func setFoodItemDown(_ food: Food, at tilePosition: TilePoint) -> [Food] {
        if !tileGroup(at: tilePosition).placeable {
            returnFoodToTouchesBegan(food)
            return [food]
        }
        
        if let existingFood = getFoodOnTile(tilePosition) {
            if let combinedItem = Recipe.combineIngredients(existingFood.foodIdentifier, food.foodIdentifier) {
                
                attemptFoodCombine(incomingFood: food, existingFood: existingFood, resultingItem: combinedItem)
                
                return [food, existingFood]
            } else {
                returnFoodToTouchesBegan(food)
                return [food]
            }
        }
        
        placeFoodOnTile(food, tilePosition)
        //food.createPortionLabel()
        food.updatePortionLabel()
        onAction(tutorialAction: .action(food.foodIdentifier, tileGroup(at: tilePosition)))
        return [food]
    }
    
    func attemptFoodCombine(incomingFood: Food, existingFood: Food, resultingItem: FoodItem)
    {
        /// Only fail if both are portionable. Errors relating to this should be caught before production, but should not fail in production.
#if DEBUG
        if incomingFood.portion != nil && existingFood.portion != nil {
            fatalError("Both incoming and existing food items cannot be portionable")
        }
#endif
        
        incomingFood.portionSingle()
        existingFood.portionSingle()
        
        /// Notify tutorial module
        onAction(tutorialAction: .combine(incomingFood.foodIdentifier, existingFood.foodIdentifier))
        
        if let incomingPortionCount = incomingFood.portion, incomingPortionCount > 0 {
            existingFood.updateFoodItem(foodItem: resultingItem)
            existingFood.updatePortionLabel()
            if let prevTouches = touchesBeganLocation {
                placeFoodOnTile(incomingFood, prevTouches)
            }
        } else if let existingPortionCount = existingFood.portion, existingPortionCount > 0 {
            incomingFood.updateFoodItem(foodItem: resultingItem)
            existingFood.updatePortionLabel()
            if let prevTouches = touchesBeganLocation {
                placeFoodOnTile(incomingFood, prevTouches)
            }
        } else {
            existingFood.updateFoodItem(foodItem: resultingItem)
            incomingFood.removeFromParent()
        }
    }
    
    func eventMachineTile(_ food: Food, at tilePosition: TilePoint) {
        food.startCooking()
    }
    
    func eventPlaceableTile(_ food: Food, at tilePosition: TilePoint) {
    }
    
    func eventTableTile(_ food: Food, at tilePosition: TilePoint) {
        for customer in customersAtTables {
            if customer.tableSittingAt == TilePoint(column: Int(tilePosition.x), row: Int(tilePosition.y)) {
                if customer.order == food.foodIdentifier {
                    customer.orderSatisfied()
                    removeCustomer(customer)
                    food.removeFromParent()
                    incrementScore(by: 1)
                    return
                }
            }
        }
    }
    
    func eventTrashTile(_ food: Food, at tilePosition: TilePoint) {
        food.removeFromParent()
    }
    
    func eventSinkTile(_ food: Food, at tilePosition: TilePoint) {
        food.sinkEvent()
    }
}

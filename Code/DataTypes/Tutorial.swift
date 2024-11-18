//
//  Tutorial.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation

enum TutorialAction: Equatable, Hashable, Identifiable {
    case combine(FoodItem, FoodItem)
    case grabSourceToTile(FoodItem, TileType)
    case grabSourceToFoodItem(FoodItem, FoodItem)
    case action(FoodItem, TileType)
    case cook(FoodItem)
    case serve(FoodItem)
    
    var id: String {
        return self.description
    }
    
    static func == (lhs: TutorialAction, rhs: TutorialAction) -> Bool {
        switch (lhs, rhs) {
        case (.combine(let food1, let food2), .combine(let food3, let food4)):
            return food1 == food3 && food2 == food4 || food1 == food4 && food2 == food3
        case (.action(let food1, let tile1), .action(let food2, let tile2)):
            return food1 == food2 && tile1 == tile2
        case (.cook(let food1), .cook(let food2)):
            return food1 == food2
        case (.serve(let food1), .serve(let food2)):
            return food1 == food2
        case (.grabSourceToTile(let food1, let tile1), .grabSourceToTile(let food2, let tile2)):
            return food1 == food2 && tile1 == tile2
        case (.grabSourceToFoodItem(let food1, let food2), .grabSourceToFoodItem(let food3, let food4)):
            return food1 == food3 && food2 == food4 || food1 == food4 && food2 == food3
        default:
            return false
        }
    }
    
    var description: String {
        switch self {
        case .combine(let food1, let food2), .grabSourceToFoodItem(let food1, let food2):
            return "Combine \(food1.description) with \(food2.description)"
        case .grabSourceToTile(let food, let tile), .action(let food, let tile):
            return "Grab \(food.description) to \(tile)"
        case .cook(let food):
            return "Wait for \(food.description) to cook"
        case .serve(let food):
            return "Grab \(food.description) and serve to customer"
        }
    }
}

protocol TutorialSceneControl: AnyObject {
    var inTutorialPhase: Bool { get set }
    var foodCategory: FoodOrderCategory { get }
    var tutorialActionSequence: [TutorialAction] { get set }
    var currentTutorialPhase: TutorialAction? { get set }
    
    func startTutorialPhase() -> Void
    func endTutorialPhase() -> Void
    
    func highlightFood(foodItem: FoodItem) -> Void
    func highlightFoodSource(foodItem: FoodItem) -> Void
    func highlightTile(tileType: TileType) -> Void
    func highlightCustomers(ordering foodItem: FoodItem) -> Void
    func highlightForTutorialPhase(nextAction: TutorialAction) -> Void
    func clearHighlights() -> Void
    
    func onAction(tutorialAction: TutorialAction) -> Void
}

extension TutorialSceneControl {
    func initiateTutorial() {
        tutorialActionSequence = foodCategory.tutorialSequence
        currentTutorialPhase = tutorialActionSequence.first
        tutorialActionSequence.removeFirst()
        
        if let nextAction = currentTutorialPhase {
            highlightForTutorialPhase(nextAction: nextAction)
        }
    }
    
    func updateHighlights() {
        if let nextAction = currentTutorialPhase {
            highlightForTutorialPhase(nextAction: nextAction)
        } else {
            clearHighlights()
        }
    }
    
    func onAction(tutorialAction: TutorialAction) {
        if tutorialAction == currentTutorialPhase {
            if let nextAction = tutorialActionSequence.first {
                currentTutorialPhase = nextAction
                tutorialActionSequence.removeFirst()
                
                highlightForTutorialPhase(nextAction: nextAction)
            } else {
                clearHighlights()
                currentTutorialPhase = nil
                if inTutorialPhase {
                    endTutorialPhase()
                }
            }
        }
    }
}

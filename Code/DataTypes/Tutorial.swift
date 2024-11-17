//
//  Tutorial.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation

enum TutorialAction: Equatable {
    case combine(FoodItem, FoodItem)
    case action(FoodItem, TileType)
    case cook(FoodItem)
    case serve(FoodItem)
    
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
        default:
            return false
        }
    }
}

protocol TutorialSceneControl: AnyObject {
    var foodCategory: FoodOrderCategory { get }
    var tutorialActionSequence: [TutorialAction] { get set }
    var currentTutorialPhase: TutorialAction? { get set }
    
    func startTutorialPhase() -> Void
    func endTutorialPhase() -> Void
    
    func highlightFood(foodItem: FoodItem) -> Void
    func highlightTile(tileType: TileType) -> Void
    func highlightCustomers(ordering foodItem: FoodItem) -> Void
    func clearHighlights() -> Void
    
    func onAction(tutorialAction: TutorialAction) -> Void
}

extension TutorialSceneControl {
    func initiateTutorial() {
        startTutorialPhase()
        tutorialActionSequence = foodCategory.tutorialSequence
        currentTutorialPhase = tutorialActionSequence.first
        tutorialActionSequence.removeFirst()
        
        if let nextAction = currentTutorialPhase {
            highlightForTutorialPhase(nextAction: nextAction)
        }
    }
    
    func highlightForTutorialPhase(nextAction: TutorialAction) {
        clearHighlights()
        switch nextAction {
        case .combine(let food1, let food2):
            highlightFood(foodItem: food1)
            highlightFood(foodItem: food2)
        case .action(let food, let tileType):
            highlightFood(foodItem: food)
            highlightTile(tileType: tileType)
        case .cook(let food):
            highlightFood(foodItem: food)
        case .serve(let food):
            highlightFood(foodItem: food)
            highlightCustomers(ordering: food)
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
                endTutorialPhase()
            }
        }
    }
}
//
//  GameScene.swift
//  DishDash
//
//  Created by Hunter Han on 10/15/24.
//

import SpriteKit
import GameplayKit
import os
import SwiftUI

class GameScene: SKScene {
    /// Assume gameContext will always be set by GameContext creating it
    var gameContext: DishDashGameContext!
    //    var tileMap: RestaurantTileMap = RestaurantTileMap(columns: 10, rows: 10, frame: UIScreen.main.bounds)
    var draggedFood: Food?
    
    var tileMap: SKTileMapNode!
    var foodSourceToolbar: SKNode!
    
    //var score: Int = 0
    //var scoreLabel: SKLabelNode!
    var customers: [Customer] = []
    
    var customerGeneratorTimer: Timer?
    
    var cuttingTimer: Timer?
    var portionTimer: Timer?
    var cuttingInProgress = false
    var portionInProgress = false
    
    var tutorialActionSequence: [TutorialAction] = []
    var currentTutorialPhase: TutorialAction? = nil
    var shouldBeginTutorial: Bool = true
    var inTutorialPhase: Bool = false
    
    convenience init(gameContext: DishDashGameContext, shouldBeginTutorial: Bool) {
        self.init(fileNamed: "DishDashGameScene")!
        self.gameContext = gameContext
        self.shouldBeginTutorial = shouldBeginTutorial
    }
    
    internal var queuedCustomersOutside: [Customer] = []
    /// Main actor prevents multiple timers from doing unexpected behavior to this array
    @MainActor internal var customersAtTables: [Customer] = []
    internal var customersSinceStart: Int = 0
    
    internal let logger = Logger(subsystem: "com.huntershan.DishDash", category: "GameScene")
    
    private let columns = 10
    private let rows = 10
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let sizeOfFoodSprites: CGSize = CGSize(width: 50, height: 50)
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        tileMap = self.childNode(withName: "Tile Map Node") as? SKTileMapNode
        foodSourceToolbar = self.childNode(withName: "FoodSourceToolbar")
        setupScoreLabel()
        startNewCustomerTimer()
        generateFoodSourcesToolbar()
        setupRecipeToolbar()
        
#if DEBUG
        drawDebugTiles()
#endif
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScoreLabel()
        if shouldBeginTutorial {
            startTutorialPhase()
            initiateTutorial()
        }
    }
    
    var background: SKShapeNode!
    
    var touchesBeganLocation: TilePoint? = nil
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        //let node = atPoint(location)
        touchesBeganLocation = nil
        
        if atPoint(location).name == "RestartButton" {
            restartGame()
        } else if atPoint(location).name == "RecipeBook" {
            self.view?.window?.rootViewController?.present(UIHostingController(rootView: RecipeInstructionView(foodItem: foodCategory.orderableItems)), animated: true)
        }
        
        if let nameSource = atPoint(location).name, nameSource.hasPrefix("FoodSource"), let foodRawValue = Int(nameSource.dropFirst("FoodSource".count)), let foodItem = FoodItem(rawValue: foodRawValue) {
            draggedFood = Food(name: foodItem, size: CGSize(width: 50, height: 50))
            if let draggedFood = draggedFood {
                draggedFood.position = location
                addChild(draggedFood)
            }
        }else {
            if let tilePosition = tilePosition(for: touch), let food = getFoodOnTile(tilePosition) {
                draggedFood = food
                
                food.stopCooking()
                touchesBeganLocation = tilePosition
            }
        }
        
        updateHighlights()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggedFood = draggedFood else { return }
        let location = touch.location(in: self)
        draggedFood.position = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggedFood = draggedFood, let tilePosition = tilePosition(for: touch) else { return }
        
        if tileMap.frame.contains(touch.location(in: self)) {
            cuttingTimer?.invalidate()
            portionTimer?.invalidate()
            draggedFood.removeTimerGuage()
            
            let itemsToFireEvents = setFoodItemDown(draggedFood, at: tilePosition)
            itemsToFireEvents.forEach { item in
                fireTileEvent(item)
            }
        } else {
            returnFoodToTouchesBegan(draggedFood)
        }
        
        self.draggedFood = nil
        updateHighlights()
    }
    
    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: self.frame.minX + 100, y: self.frame.maxY - 100)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
    }
    
    func incrementScore(by points: Int) {
        score += points
    }
}

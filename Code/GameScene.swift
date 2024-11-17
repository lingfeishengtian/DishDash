//
//  GameScene.swift
//  DishDash
//
//  Created by Hunter Han on 10/15/24.
//

import SpriteKit
import GameplayKit
import os

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
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        tileMap = self.childNode(withName: "Tile Map Node") as? SKTileMapNode
        foodSourceToolbar = self.childNode(withName: "FoodSourceToolbar")
        setupScoreLabel()
        startNewCustomerTimer()
        generateFoodSourcesToolbar()
    }
    
    //lol i cant get it in view without this, figure this out later
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScoreLabel()
    }
    
    var background: SKShapeNode!
    
    var touchesBeganLocation: TilePoint? = nil
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        //let node = atPoint(location)
        touchesBeganLocation = nil
        
        
        if let nameSource = atPoint(location).name, nameSource.hasPrefix("FoodSource"), let foodRawValue = Int(nameSource.dropFirst("FoodSource".count)), let foodItem = FoodItem(rawValue: foodRawValue) {
            draggedFood = Food(name: foodItem, size: CGSize(width: 50, height: 50))
            if let draggedFood = draggedFood {
                draggedFood.position = location
                addChild(draggedFood)
            }
        }else {
            let tileMaplocation = touch.location(in: tileMap)
            let column = tileMap.tileColumnIndex(fromPosition: tileMaplocation)
            let row = tileMap.tileRowIndex(fromPosition: tileMaplocation)
            let tilePosition = TilePoint(column: column, row: row)
            if let food = getFoodOnTile(tilePosition) {
                draggedFood = food
                
                if let (action, slicedFood) = Recipe.action(for: food.foodIdentifier), action == .Cut {
                    cuttingInProgress = true
                    cuttingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {_ in
                        food.updateFoodItem(foodItem: slicedFood)
                        return
                    
                    }
                    food.createTimerGuage(time: 3)
                } else {
                    food.position = location
                }
                
                food.stopCooking()
                touchesBeganLocation = TilePoint(x: column, y: row) }
            
        }
    
        
        if atPoint(location).name == "RestartButton" {
            restartGame()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggedFood = draggedFood else { return }
        let location = touch.location(in: self)
        if cuttingInProgress || portionInProgress{
            // calculate distance from original location
            let distance = sqrt(pow(location.x - draggedFood.position.x, 2) + pow(location.y - draggedFood.position.y, 2))
            if distance > 50 {
                cuttingTimer?.invalidate()
                cuttingInProgress = false
                portionTimer?.invalidate()
                portionInProgress = false
                draggedFood.removeTimerGuage()
            } else {
                return
            }
        }
        draggedFood.position = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggedFood = draggedFood else { return }
        let positionInTileMap = touch.location(in: tileMap)
        let column = tileMap.tileColumnIndex(fromPosition: positionInTileMap)
        let row = tileMap.tileRowIndex(fromPosition: positionInTileMap)
        let tilePosition = TilePoint(column: column, row: row)
        
        cuttingTimer?.invalidate()
        portionTimer?.invalidate()
        draggedFood.removeTimerGuage()
        
        if let tileGroup = tileMap.tileGroup(atColumn: column, row: row), setFoodItemDown(draggedFood, at: tilePosition) {
            switch tileGroup.name {
            case TileType.machine.rawValue:
                placeFoodOnMachineTile(draggedFood, at: tilePosition)
            case TileType.counter.rawValue:
                placeFoodOnNonMachineTile(draggedFood, at: tilePosition)
            case TileType.sink.rawValue:
                eventItemPlacedOnSink(draggedFood, at: tilePosition)
            case TileType.table.rawValue:
                eventItemPlacedOnTable(draggedFood, at: tilePosition)
            case TileType.trashcan.rawValue:
                placeFoodOnTrashTile(draggedFood, at: tilePosition)
            default:
                returnFoodToTouchesBegan(draggedFood)
            }
        } else {
            returnFoodToTouchesBegan(draggedFood)
        }
        
        self.draggedFood = nil
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

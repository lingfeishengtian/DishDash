//
//  GameScene.swift
//  DishDash
//
//  Created by Hunter Han on 10/15/24.
//

import SpriteKit
import GameplayKit

enum TileType: String, CaseIterable {
    case counter = "Counter"
    case machine = "Machine"
    case floor = "Floor"
    case table = "Table"
    case sink = "Sink"
    
    var color: UIColor {
        switch self {
        case .counter:
            return .gray
        case .machine:
            return .blue
        case .floor:
            return .white
        case .table:
            return .brown
        case .sink:
            return .cyan
        }
    }
}

struct TilePoint: Hashable {
    let x: Int
    let y: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

class GameScene: SKScene {
    /// Assume gameContext will always be set by GameContext creating it
    var gameContext: DishDashGameContext!
    //    var tileMap: RestaurantTileMap = RestaurantTileMap(columns: 10, rows: 10, frame: UIScreen.main.bounds)
    var draggedFood: Food?
    var foodOnTile: [CGPoint: Food] = [:]
    
    var tileMap: SKTileMapNode!
    
    //var score: Int = 0
    //var scoreLabel: SKLabelNode!
    var customers: [Customer] = []
    var tablePositions: [CGPoint] = []
    
    var customerGeneratorTimer: Timer?
    
    private let columns = 10
    private let rows = 10
    
    private let baseCustomerSpawnRate: Int = 10
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        tileMap = self.childNode(withName: "Tile Map Node") as? SKTileMapNode
        setupScoreLabel()
        customerGeneratorTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(baseCustomerSpawnRate), repeats: false) { [weak self] _ in
            print("Resrving table")
            self?.addCustomer()
        }
    }
    //lol i cant get it in view without this, figure this out later
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScoreLabel()
    }
    
    private var customersSinceStart: Int = 0
    /// Reduce seconds linearly from 10 to 5 based on customers since start
    /// Reduce seconds exponentially after 20 customers
    private func timeIntervalBasedOnDifficulty() -> TimeInterval {
        if customersSinceStart < 20 {
            return TimeInterval(max(baseCustomerSpawnRate - Int((Double(customersSinceStart) / 20.0) * (Double(baseCustomerSpawnRate) / 2)), 3))
        } else {
            return TimeInterval(max(baseCustomerSpawnRate / 2 - Int(pow(Double(customersSinceStart) / 20.0, 1.5)), 3))
        }
    }
    
    private var queuedCustomersOutside: [Customer] = []
    /// Main actor prevents multiple timers from doing unexpected behavior to this array
    @MainActor private var customersAtTables: [Customer] = []
    func addCustomer() {
        let newCustomer = Customer(order: FoodItem.randomOrderableItem(options: .sushi), timeLimit: 1, size: CGSize(width: 50, height: 50)) {
            print("Customer left")
            self.loseGame()
        }
        
        if let reservedTable = reserveTable(for: newCustomer) {
            newCustomer.position = reservedTable
            self.addChild(newCustomer)
            
            customersAtTables.append(newCustomer)
            customersSinceStart += 1
            
            customerGeneratorTimer = Timer.scheduledTimer(withTimeInterval: timeIntervalBasedOnDifficulty(), repeats: false) { [weak self] _ in
                self?.addCustomer()
            }
        } else {
            // TODO: Implement outside queueing
            loseGame()
        }
    }
    
    func removeCustomer(_ customer: Customer) {
        customersAtTables.removeAll { $0 == customer }
        customer.removeFromParent()
    }
    
    // TODO: Implement loseGame
    func loseGame() {
        showLosingScreen()
    }
    
    var background: SKShapeNode!
    private func showLosingScreen() {
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
    
    
    /// Reserves a table at a TilePoint (sets the customer's table to this tile point) and returns the coordinates that customer should "sit" at
    func reserveTable(for customer: Customer) -> CGPoint? {
        let positions = getPositionsOfTileGroup(for: TileType.table)
        
        for tablePosition in positions {
            if !customersAtTables.contains(where: { $0.tableSittingAt == tablePosition }) {
                customer.tableSittingAt = tablePosition
                
                // TODO: Handle table positioning code (x - 1) is a placeholder
                return self.convert(tileMap.centerOfTile(atColumn: tablePosition.x - 1, row: tablePosition.y), from: tileMap)
            }
        }
        
        return nil
    }
    
    /// Get all available positions of a tile group
    func getPositionsOfTileGroup(for tileType: TileType) -> [TilePoint] {
        var tablePositions: [TilePoint] = []
        
        for column in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if let tileGroup = tileMap.tileGroup(atColumn: column, row: row)?.name, tileGroup == tileType.rawValue {
                    tablePositions.append(TilePoint(x: column, y: row))
                }
            }
        }
        
        return tablePositions
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        //let node = atPoint(location)
        
        if atPoint(location).name == "FoodSource" {
//            draggedFood = Food(name: .SteakRaw, size: CGSize(width: 32, height: 32))
            draggedFood = Food(name: .PotRawRice, size: CGSize(width: 32, height: 32))
            if let draggedFood = draggedFood {
                draggedFood.position = location
                addChild(draggedFood)
            }
        } else {
            let tileMaplocation = touch.location(in: tileMap)
            let column = tileMap.tileColumnIndex(fromPosition: tileMaplocation)
            let row = tileMap.tileRowIndex(fromPosition: tileMaplocation)
            let tilePosition = CGPoint(x: column, y: row)
            if let food = foodOnTile[tilePosition] {
                food.position = location
                food.stopCooking()
                draggedFood = food
                foodOnTile[tilePosition] = nil
            }
        }
        
        if atPoint(location).name == "RestartButton" {
            restartGame()
            background.removeFromParent()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggedFood = draggedFood else { return }
        let location = touch.location(in: self)
        draggedFood.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let draggedFood = draggedFood else { return }
        let positionInTileMap = touch.location(in: tileMap)
        let column = tileMap.tileColumnIndex(fromPosition: positionInTileMap)
        let row = tileMap.tileRowIndex(fromPosition: positionInTileMap)
        let tilePosition = CGPoint(x: column, y: row)
        //let location = touch.location(in: self)
        //let node = atPoint(location)
        
        
        if let tileGroup = tileMap.tileGroup(atColumn: column, row: row) {
            switch tileGroup.name {
            case TileType.machine.rawValue:
                placeFoodOnMachineTile(draggedFood, at: tilePosition)
            case TileType.counter.rawValue:
                placeFoodOnNonMachineTile(draggedFood, at: tilePosition)
            case TileType.sink.rawValue:
                eventItemPlacedOnSink(draggedFood, at: tilePosition)
            case TileType.table.rawValue:
                eventItemPlacedOnTable(draggedFood, at: tilePosition)
            default:
                draggedFood.removeFromParent()
            }
        }
        
        self.draggedFood = nil
    }
    
    private func setFoodItemDown(_ food: Food, at tilePosition: CGPoint) {
        let positionInTileMap = tileMap.convert(tileMap.centerOfTile(atColumn: Int(tilePosition.x), row: Int(tilePosition.y)), to: self)
        food.removeFromParent()
        self.addChild(food)
        food.position = positionInTileMap
        food.scale(to: CGSize(width: 50, height: 50))
        foodOnTile[tilePosition] = food
        food.stopCooking()
    }
    
    private func placeFoodOnMachineTile(_ food: Food, at tilePosition: CGPoint) {
        setFoodItemDown(food, at: tilePosition)
        food.startCooking()
    }
    
    private func placeFoodOnNonMachineTile(_ food: Food, at tilePosition: CGPoint) {
        setFoodItemDown(food, at: tilePosition)
    }
    
    private func eventItemPlacedOnTable(_ food: Food, at tilePosition: CGPoint) {
        setFoodItemDown(food, at: tilePosition)
        
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
    
    private func eventItemPlacedOnSink(_ food: Food, at tilePosition: CGPoint) {
        setFoodItemDown(food, at: tilePosition)
        food.sinkEvent()
    }
    
    
    func restartGame() {
        self.customers.removeAll()
        self.customersAtTables.removeAll()
        self.queuedCustomersOutside.removeAll()
        self.customersSinceStart = 0
        self.draggedFood?.removeFromParent()
        self.draggedFood = nil
        self.foodOnTile.removeAll()
        
        for node in self.children {
            if node != tileMap && node != scoreLabel && node.name != "FoodSource" {
                node.removeFromParent()
            }
        }
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
    
    
    deinit {
        print("GameScene deinited")
    }
}

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
    
    var score: Int = 0
    var scoreLabel: SKLabelNode!
    var customers: [Customer] = []
    var tablePositions: [CGPoint] = []
    
    var customerGeneratorTimer: Timer?
    
    private let columns = 10
    private let rows = 10
    
    private let baseCustomerSpawnRate: Int = 10
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        tileMap = self.childNode(withName: "Tile Map Node") as? SKTileMapNode
        
        customerGeneratorTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(baseCustomerSpawnRate), repeats: false) { [weak self] _ in
            print("Resrving table")
            self?.addCustomer()
        }
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
        let newCustomer = Customer(order: FoodItem.randomOrderableItem(), timeLimit: 10, size: CGSize(width: 50, height: 50)) {
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
        print("You lost!")
        fatalError()
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
        
        if atPoint(location).name == "FoodSource" {
            draggedFood = Food(name: .SteakRaw, size: CGSize(width: 32, height: 32))
            if let draggedFood = draggedFood {
                draggedFood.position = location
                addChild(draggedFood)
            }
        } else {
            location = touch.location(in: tileMap)
            let column = tileMap.tileColumnIndex(fromPosition: location)
            let row = tileMap.tileRowIndex(fromPosition: location)
            let tilePosition = CGPoint(x: column, y: row)
            if let food = foodOnTile[tilePosition] {
                location = touch.location(in: self)
                food.position = location
                food.stopCooking()
                draggedFood = food
                foodOnTile[tilePosition] = nil
            }
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
        
        if let tileGroup = tileMap.tileGroup(atColumn: column, row: row) {
            switch tileGroup.name {
            case TileType.machine.rawValue:
                placeFoodOnMachineTile(draggedFood, at: tilePosition)
            case TileType.counter.rawValue, TileType.sink.rawValue:
                placeFoodOnNonMachineTile(draggedFood, at: tilePosition)
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
                    self.score += 1
                    return
                }
            }
        }
    }
}

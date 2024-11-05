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

class GameScene: SKScene {
//    var tileMap: RestaurantTileMap = RestaurantTileMap(columns: 10, rows: 10, frame: UIScreen.main.bounds)
    var draggedFood: Food?
    var foodOnTile: [CGPoint: Food] = [:]
    
    var tileMap: SKTileMapNode!
    
    private let columns = 10
    private let rows = 10
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        tileMap = self.childNode(withName: "Tile Map Node") as? SKTileMapNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if atPoint(location).name == "FoodSource" {
            draggedFood = Food(name: "Ingredient", size: CGSize(width: 32, height: 32))
            if let draggedFood = draggedFood {
                draggedFood.position = location
                addChild(draggedFood)
            }
        } else {
            let column = tileMap.tileColumnIndex(fromPosition: location)
            let row = tileMap.tileRowIndex(fromPosition: location)
            let tilePosition = CGPoint(x: column, y: row)
            if let food = foodOnTile[tilePosition] {
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
        let location = touch.location(in: self)
        
        let positionInTileMap = touch.location(in: tileMap)
        let column = tileMap.tileColumnIndex(fromPosition: positionInTileMap)
        let row = tileMap.tileRowIndex(fromPosition: positionInTileMap)
        let tilePosition = CGPoint(x: column, y: row)
        
        if let tileGroup = tileMap.tileGroup(atColumn: column, row: row),
           
            tileGroup.name == TileType.counter.rawValue ||
            tileGroup.name == TileType.machine.rawValue ||
            tileGroup.name == TileType.sink.rawValue ||
            tileGroup.name == TileType.table.rawValue {
            let positionInTileMap = tileMap.centerOfTile(atColumn: column, row: row)
            draggedFood.removeFromParent()
            tileMap.addChild(draggedFood)
            draggedFood.position = positionInTileMap
            draggedFood.scale(to: CGSize(width: 100, height: 100))
            foodOnTile[tilePosition] = draggedFood
        } else {
            
            draggedFood.removeFromParent()
        }
        
        self.draggedFood = nil
    }
}

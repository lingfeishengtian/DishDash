//
//  GameScene.swift
//  DishDash
//
//  Created by Hunter Han on 10/15/24.
//

import SpriteKit
import GameplayKit

enum TileType: String {
    case counter = "Counter"
    case machine = "Machine"
    case floor = "Floor"
    case table = "Table"
    case sink = "Sink"
}

class GameScene: SKScene {
    var tileMap: SKTileMapNode?
    var draggedFood: Food?
    var foodOnTile: [CGPoint: Food] = [:]
    
    private let columns = 10
    private let rows = 10
    
    override func didMove(to view: SKView) {
        setupTileMap()
        setupFoodSource()
    }
    
    private var tileSize: CGSize {
        let sideLength = min(frame.width / CGFloat(columns), frame.height / CGFloat(rows))
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func setupTileMap() {
        let tileSize = tileSize
        
        let tileSet = createBasicTileSet()
        
        tileMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        
        if let tileMap = tileMap {
            let mapWidth = CGFloat(columns) * tileSize.width
            let mapHeight = CGFloat(rows) * tileSize.height
            let xScale = frame.width / mapWidth
            let yScale = frame.height / mapHeight
            let scale = min(xScale, yScale)
            tileMap.setScale(scale)
            tileMap.position = CGPoint(x: frame.midX, y: frame.midY)
            tileMap.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            addChild(tileMap)
            
            fillTileMap(with: .floor)
            setTile(at: (5, 5), tileType: .counter)
            setTile(at: (5, 6), tileType: .machine)
            setTile(at: (5, 7), tileType: .sink)
            setTile(at: (7, 9), tileType: .table)
        }
    }
    
    func fillTileMap(with defaultTileType: TileType) {
        guard let tileMap = tileMap else { return }
        
        for column in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                setTile(at: (column, row), tileType: defaultTileType)
            }
        }
    }
    
    func setTile(at position: (Int, Int), tileType: TileType) {
        guard let tileMap = tileMap else { return }
        
        if let tileGroup = tileMap.tileSet.tileGroups.first(where: { $0.name == tileType.rawValue }) {
            
#if DEBUG
            // add text indicating row and column
            let label = SKLabelNode(text: "\(position.0), \(position.1)")
            label.fontSize = 10
            label.fontColor = .black
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.position = tileMap.centerOfTile(atColumn: position.0, row: position.1)
            tileMap.addChild(label)
#endif
            tileMap.setTileGroup(tileGroup, forColumn: position.0, row: position.1)
        }
    }
    
    func createBasicTileSet() -> SKTileSet {
        let colors: [TileType: UIColor] = [
            .floor: .lightGray,
            .counter: .gray,
            .machine: .darkGray,
            .sink: .blue,
            .table: .brown,
            
        ]
        
        var tileGroups = [SKTileGroup]()
        
        for (tileType, color) in colors {
            let colorNode = SKSpriteNode(color: color, size: tileSize)
            
            let texture = SKView().texture(from: colorNode)
            let tileDefinition = SKTileDefinition(texture: texture!, size: tileSize)
            tileDefinition.userData = ["color": color]
            
            let tileGroup = SKTileGroup(tileDefinition: tileDefinition)
            tileGroup.name = tileType.rawValue
            tileGroups.append(tileGroup)
            
        }
        
        return SKTileSet(tileGroups: tileGroups)
    }
    func setupFoodSource() {
        let sourceNode = SKShapeNode(circleOfRadius: 20)
        sourceNode.position = CGPoint(x: 100, y: 100)
        sourceNode.fillColor = .green
        sourceNode.name = "FoodSource"
        addChild(sourceNode)
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
        } else if let tileMap = tileMap {
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
        
        if let tileMap = tileMap {
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
                foodOnTile[tilePosition] = draggedFood
            } else {
                
                draggedFood.removeFromParent()
            }
        }
        
        self.draggedFood = nil
    }
}

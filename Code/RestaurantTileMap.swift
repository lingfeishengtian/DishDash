//
//  RestaurantTileMap.swift
//  DishDash
//
//  Created by Hunter Han on 11/4/24.
//

import SpriteKit
import GameplayKit

class RestaurantTileMap: SKTileMapNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(columns: Int, rows: Int, frame: CGRect) {
        super.init()
        
        self.numberOfColumns = columns
        self.numberOfRows = rows
        
        let sideLength = min(frame.width / CGFloat(columns), frame.height / CGFloat(rows))
        self.tileSize = CGSize(width: sideLength, height: sideLength)
        
        setupTileMap()
    }
    
    func setTile(at position: (Int, Int), tileType: TileType) {
        if let tileGroup = self.tileSet.tileGroups.first(where: { $0.name == tileType.rawValue }) {
            
#if DEBUG
            // add text indicating row and column
            let label = SKLabelNode(text: "\(position.0), \(position.1)")
            label.fontSize = 10
            label.fontColor = .black
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.position = self.centerOfTile(atColumn: position.0, row: position.1)
            self.addChild(label)
#endif
            self.setTileGroup(tileGroup, forColumn: position.0, row: position.1)
        }
    }
    
    private func setupTileMap() {        
        let tileSet = createBasicTileSet()
        
        self.tileSet = tileSet
        
        fillTileMap(with: .floor)
        setTile(at: (5, 5), tileType: .counter)
        setTile(at: (5, 6), tileType: .machine)
        setTile(at: (5, 7), tileType: .sink)
        setTile(at: (7, 9), tileType: .table)
    }
    
    private func fillTileMap(with defaultTileType: TileType) {
        for column in 0..<self.numberOfColumns {
            for row in 0..<self.numberOfRows {
                setTile(at: (column, row), tileType: defaultTileType)
            }
        }
    }
    
    private func createBasicTileSet() -> SKTileSet {
        var tileGroups = [SKTileGroup]()
        
        for tileType in TileType.allCases {
            let colorNode = SKSpriteNode(color: tileType.color, size: tileSize)
            
            let texture = SKView().texture(from: colorNode)
            let tileDefinition = SKTileDefinition(texture: texture!, size: tileSize)
            tileDefinition.userData = ["color": tileType.color]
            
            let tileGroup = SKTileGroup(tileDefinition: tileDefinition)
            tileGroup.name = tileType.rawValue
            tileGroups.append(tileGroup)
        }
        
        return SKTileSet(tileGroups: tileGroups)
    }
}

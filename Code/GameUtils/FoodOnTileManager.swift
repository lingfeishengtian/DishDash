//
//  FoodOnTileManager.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation

extension GameScene {
    /// Get all available positions of a tile group
    func getPositionsOfTileGroup(for tileType: TileType) -> [TilePoint] {
        var tablePositions: [TilePoint] = []
        
        for column in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if let tileGroup = tileMap.tileGroup(atColumn: column, row: row)?.name, tileGroup == tileType.rawValue {
                    tablePositions.append(TilePoint(column: column, row: row))
                }
            }
        }
        
        return tablePositions
    }
    
    func tileGroup(at tile: TilePoint) -> TileType {
        let tileGroup = tileMap.tileGroup(atColumn: tile.x, row: tile.y)
        return TileType(rawValue: tileGroup?.name ?? "") ?? .unknown
    }

    
    func convertTilePointToGameSceneCoords(_ tile: TilePoint) -> CGPoint {
        let coords = tileMap.centerOfTile(atColumn: tile.x, row: tile.y)
        return self.convert(coords, from: tileMap)
    }
    
    func getFoodOnTile(_ tile: TilePoint) -> Food? {
        let coords = convertTilePointToGameSceneCoords(tile)
        let nodes = nodes(at: coords)
        
        for node in nodes {
            if let food = node as? Food, food != draggedFood {
                return food
            }
        }
        
        return nil
    }
    
    // Convenience function for optional tile
    func returnFoodToTouchesBegan(_ food: Food) {
        guard let touchesBeganLocation else {
            food.removeFromParent()
            return
        }
        placeFoodOnTile(food, touchesBeganLocation)
    }
    
    func placeFoodOnTile(_ food: Food, _ tile: TilePoint) {
        let coords = convertTilePointToGameSceneCoords(tile)
        food.position = coords
        food.zPosition = 1
        food.scale(to: sizeOfFoodSprites)
        
        if food.parent != nil {
            food.removeFromParent()
        }
        
        food.stopCooking()
        addChild(food)
    }
}

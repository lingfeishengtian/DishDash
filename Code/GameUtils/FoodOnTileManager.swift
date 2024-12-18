//
//  FoodOnTileManager.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation
import UIKit

extension GameScene {
    func tilePosition(for touch: UITouch) -> TilePoint? {
        let positionInTileMap = touch.location(in: tileMap)
        let column = tileMap.tileColumnIndex(fromPosition: positionInTileMap)
        let row = tileMap.tileRowIndex(fromPosition: positionInTileMap)
        return TilePoint(column: column, row: row)
    }
    
    /// In terms of scene coordinates
    func tilePosition(for position: CGPoint) -> TilePoint? {
        let convertedPosition = convert(position, to: tileMap)
        let column = tileMap.tileColumnIndex(fromPosition: convertedPosition)
        let row = tileMap.tileRowIndex(fromPosition: convertedPosition)
        return TilePoint(column: column, row: row)
    }
    
    func position(of food: Food) -> TilePoint {
        let foodPosition = food.position
        let tileMapPosition = convert(foodPosition, to: tileMap)
        let column = tileMap.tileColumnIndex(fromPosition: tileMapPosition)
        let row = tileMap.tileRowIndex(fromPosition: tileMapPosition)
        return TilePoint(column: column, row: row)
    }
    
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
    
    func getAllFoodOnscreen() -> [Food] {
        return children.compactMap { $0 as? Food }
    }
}

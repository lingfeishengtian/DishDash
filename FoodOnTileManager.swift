//
//  FoodOnTileManager.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation

extension GameScene {
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
    
    func placeFoodOnTile(_ food: Food, _ tile: TilePoint) {
        let coords = convertTilePointToGameSceneCoords(tile)
        food.position = coords
        food.zPosition = 1
        
        addChild(food)
    }
}

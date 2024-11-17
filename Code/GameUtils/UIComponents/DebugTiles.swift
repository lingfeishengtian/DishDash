//
//  DebugTiles.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation

fileprivate let tilesToIndicate: [TileType] = [.counter, .sink]

extension GameScene {
    func drawDebugTiles() {
        for tile in tilesToIndicate {
            for tilePosition in getPositionsOfTileGroup(for: tile) {
                let label = generateDefaultGameSceneLabel(
                    text: tile.rawValue,
                    fontSize: 10,
                    position: convertTilePointToGameSceneCoords(tilePosition)
                )
                label.position.y -= 20
                label.zPosition = 8
                label.fontColor = .black
                addChild(label)
            }
        }
    }
}

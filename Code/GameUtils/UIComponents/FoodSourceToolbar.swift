//
//  FoodSourceToolbar.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation
import SpriteKit

extension GameScene {
    func generateFoodSourcesToolbar() {
        // clear current toolbar
        foodSourceToolbar.removeAllChildren()
       // let foodCategory: FoodOrderCategory = currentLevel == 1 ? .Steak : .All
        let sources = foodCategory.foodSources
        let widthOfToolbar = foodSourceToolbar.frame.width
        let spacing = widthOfToolbar / CGFloat(sources.count)
        
        for (index, source) in sources.enumerated() {
            let foodSourceItem = SKSpriteNode(imageNamed: source.assetName)
            foodSourceItem.name = "FoodSource\(source.rawValue)"
            foodSourceItem.size = CGSize(width: 50, height: 50)
            let spacingBeforeAfter = (spacing - 50) / 2
            foodSourceItem.position = CGPoint(x: foodSourceToolbar.frame.minX + CGFloat(index * 2 + 1) * spacingBeforeAfter + 50 / 2 + 50 * CGFloat(index), y: 0)
            
            foodSourceToolbar.addChild(foodSourceItem)
        }
    }
}

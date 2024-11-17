//
//  RecipeToolbar.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation
import SpriteKit

fileprivate let basex: CGFloat = 0
fileprivate let basey: CGFloat = 300

extension GameScene {
    func setupRecipeToolbar() {
        let recipeList = foodCategory.tutorialSequence
        
        for sequence in recipeList {
            switch sequence {
            case .combine(let item1, let item2):
                let food1 = Food(name: item1, size: .init(width: 50, height: 50))
                let food2 = Food(name: item2, size: .init(width: 50, height: 50))
                let additionText = SKLabelNode(text: "+")
                additionText.position = CGPoint(x: basex + 50, y: basey)
                let equalsText = SKLabelNode(text: "=")
                equalsText.position = CGPoint(x: basex + 100, y: basey)
                
                food1.position = CGPoint(x: basex, y: basey)
                food2.position = CGPoint(x: basex + 50, y: basey)
                
                food1.position = CGPoint(x: basex, y: basey)
                food2.position = CGPoint(x: basex + 50, y: basey)
                
                addChild(food1)
                addChild(additionText)
                addChild(food2)
                addChild(equalsText)
                
                if let result = Recipe.combineIngredients(food1.foodIdentifier, food2.foodIdentifier) {
                    
                }
            case .action(_, _):
                break
            case .cook(_):
                break
            case .serve(_):
                break
            }
        }
    }
}

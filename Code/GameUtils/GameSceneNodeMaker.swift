//
//  GameSceneNodeMaker.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation
import SpriteKit

extension GameScene {
    func generateDefaultGameSceneLabel(text: String, fontSize: CGFloat = 30, position: CGPoint = .zero) -> SKLabelNode {
        let labelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        labelNode.text = text
        labelNode.fontSize = fontSize
        labelNode.position = position
        labelNode.numberOfLines = 0
        labelNode.lineBreakMode = .byWordWrapping
        
        return labelNode
    }
}

//
//  SKSpriteNode+GlowEffect.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation
import SpriteKit

extension SKSpriteNode {
    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
//        let effect = SKSpriteNode(texture: texture, size: size.applying(.init(scaleX: 2, y: 2)))
        let effect = SKSpriteNode(color: .systemYellow, size: size)
        effect.color = .systemGreen
        effect.colorBlendFactor = 1
        effectNode.addChild(effect)
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":radius])
        
        effectNode.isUserInteractionEnabled = false
        effect.isUserInteractionEnabled = false
        
        effectNode.zPosition = -1
    }
    
    func removeAllEffects() {
        for child in children {
            if let effectNode = child as? SKEffectNode {
                effectNode.removeFromParent()
            }
        }
    }
}

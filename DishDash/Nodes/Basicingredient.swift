//
//  basicingredient.swift
//  DishDash
//
//  Created by Kate Zheng on 11/2/24.
//
import SpriteKit

class Food: SKSpriteNode {
    var foodName: String
    var isIngredient: Bool
    var isFinalProduct: Bool

    init(name: String, size: CGSize, isIngredient: Bool = true, isFinalProduct: Bool = false) {
        self.foodName = name
        self.isIngredient = isIngredient
        self.isFinalProduct = isFinalProduct
        
        
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
        let shapeNode = SKShapeNode(path: circlePath.cgPath)
        shapeNode.fillColor = .green
        shapeNode.lineWidth = 0

        
        let texture = SKView().texture(from: shapeNode)!
        
        super.init(texture: texture, color: .clear, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//
//  Customer.swift
//  DishDash
//
//  Created by Kate Zheng on 11/7/24.
//
import SpriteKit
import os

enum FacialExpressions : String {
    case happy = "HappyFacialExpression"
    case neutral = "NeutralFacialExpression"
    case angry = "SadFacialExpression"
}

class Customer: DDEntity {
    var order: FoodItem
    private var seconds: Int
    private var orderLabel: SKLabelNode!
    private var onPatienceRunOut: (() -> Void)
    internal let logger = Logger(subsystem: "com.hunterhan.DishDash", category: "Customer")
    
    var tableSittingAt: TilePoint?
    
    init(order: FoodItem, timeLimit: Int, size: CGSize, onPatienceRunOut: @escaping () -> Void) {
        self.order = order
        self.seconds = timeLimit
        self.onPatienceRunOut = onPatienceRunOut
        self.currentCustomerHappiness = .happy
        
        super.init(texture: SKTexture(imageNamed: FacialExpressions.happy.rawValue), color: .clear, size: size)
        self.name = "Customer"
        
        setupOrderLabel(size: size)
        startCountdown()
    }
    
    func orderSatisfied() {
        served()
        // TODO: Change status to eating and set timer
        // Notify tutorial that food is served
        if let parent = self.parent as? GameScene {
            parent.onAction(tutorialAction: .serve(order))
        }
        
        // Show amount of points earned
        let pointsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pointsLabel.text = "+\(score)"
        pointsLabel.fontColor = .green
        pointsLabel.fontSize = 20
        pointsLabel.position = self.position
        pointsLabel.zPosition = 10
        
        self.parent?.addChild(pointsLabel)
        self.removeFromParent()
        
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.5)
        moveUp.timingMode = .easeInEaseOut
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let group = SKAction.group([moveUp, fadeOut])
        pointsLabel.run(group) {
            pointsLabel.removeFromParent()
        }
        
        // TODO: Find why this portion is needed
        if let parent = self.parent as? GameScene, let customerPosition = parent.tilePosition(for: self.position) {
            if let foodServed = parent.getFoodOnTile(TilePoint(column: customerPosition.column + 1, row: customerPosition.row)) {
                foodServed.removeFromParent()
            }
        }
    }
    
    var score: Int {
        switch currentCustomerHappiness {
        case .happy:
            return 3
        case .neutral:
            return 2
        case .angry:
            return 1
        }
    }
    
    var currentCustomerHappiness: FacialExpressions {
        didSet {
            self.texture = SKTexture(imageNamed: currentCustomerHappiness.rawValue)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startCountdown() {
        if seconds < 0 {
            return
        }
        
        startTimer(withSeconds: seconds) {
            self.onPatienceRunOut()
        } onTick: { tickTime in
            switch tickTime / Double(self.seconds) {
            case 0.66..<1.0:
                self.currentCustomerHappiness = .happy
            case 0.33..<0.66:
                self.currentCustomerHappiness = .neutral
            case 0..<0.33:
                self.currentCustomerHappiness = .angry
            default:
                self.currentCustomerHappiness = .angry
            }
        }
    }
    
    private func served() {
        stopTimer()
    }
}

// MARK - UI Element creation helper
extension Customer {
    private func setupOrderLabel(size: CGSize) {
        let textBox = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        textBox.fillColor = .white
        textBox.strokeColor = .black
        textBox.position = CGPoint(x: 0, y: size.height / 2 + 10)
        
        let orderImage = SKSpriteNode(imageNamed: order.assetName)
        orderImage.size = CGSize(width: size.width / 2, height: size.height / 2)
        orderImage.position = CGPoint(x: 0, y: 0)
        orderImage.scale(to: CGSize(width: size.width, height: size.height))
        
        addChild(textBox)
        textBox.addChild(orderImage)
        
        // animate bouncing up down
        let moveUp = SKAction.moveBy(x: 0, y: 5, duration: 0.5)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SKAction.moveBy(x: 0, y: -5, duration: 0.5)
        moveDown.timingMode = .easeInEaseOut
        let moveSequence = SKAction.sequence([moveUp, moveDown])
        textBox.run(SKAction.repeatForever(moveSequence))
    }
}

//
//  Customer.swift
//  DishDash
//
//  Created by Kate Zheng on 11/7/24.
//
import SpriteKit
import os

class Customer: DDEntity {
    var order: FoodItem
    private var seconds: Int
    private var waitingTimer: Timer?
    private var orderLabel: SKLabelNode!
    private var onPatienceRunOut: (() -> Void)
    internal let logger = Logger(subsystem: "com.hunterhan.DishDash", category: "Customer")
    
    var tableSittingAt: TilePoint?
    
    init(order: FoodItem, timeLimit: Int, size: CGSize, onPatienceRunOut: @escaping () -> Void) {
        self.order = order
        self.seconds = timeLimit
        self.onPatienceRunOut = onPatienceRunOut
        
        let circle = SKShapeNode(circleOfRadius: size.width / 2)
        circle.fillColor = .orange
        let texture = SKView().texture(from: circle)!
        
        super.init(texture: texture, color: .clear, size: size)
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
        self.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startCountdown() {
        if seconds < 0 {
            return
        }
        
        waitingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.seconds -= 1
            
            if self.seconds <= 0 {
                onPatienceRunOut()
                timer.invalidate()
            } else {
                logger.info("\(self.seconds) seconds left for customer")
            }
        }
        createTimerGuage(time: seconds)
    }
    
    func stopCountdown() {
        waitingTimer?.invalidate()
        waitingTimer = nil
    }
    
    private func served() {
        waitingTimer?.invalidate()
        waitingTimer = nil
    }
    
    deinit {
        waitingTimer?.invalidate()
    }
    
}

// MARK - UI Element creation helper
extension Customer {
    private func setupOrderLabel(size: CGSize) {
        let textBox = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        textBox.fillColor = .white
        textBox.strokeColor = .black
        textBox.position = CGPoint(x: 0, y: size.height / 2 + 5)
        
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

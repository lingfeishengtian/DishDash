//
//  Customer.swift
//  DishDash
//
//  Created by Kate Zheng on 11/7/24.
//
import SpriteKit

class Customer: SKSpriteNode{
    var order: FoodItem
    private var seconds: Int
    private var waitingTimer: Timer?
    private var orderLabel: SKLabelNode!
    private var onPatienceRunOut: (() -> Void)
    
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
    
    private var timerGuage: SKSpriteNode?
    func createTimerGuage(time: Int) {
        timerGuage = SKSpriteNode(color: .red, size: CGSize(width: self.size.width, height: 5))
        timerGuage?.position = CGPoint(x: 0, y: -self.size.height / 2 - 5)
        addChild(timerGuage!)
        
        let timerGuageWidth = self.size.width
        self.timerGuage?.run(SKAction.resize(byWidth: -timerGuageWidth, height: 0, duration: Double(time)))
    }
    
    func removeTimerGuage() {
        timerGuage?.removeFromParent()
    }
    
    func orderSatisfied() {
        served()
        // TODO: Change status to eating and set timer
        self.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") }
    
    private func setupOrderLabel(size: CGSize) {
//        orderLabel = SKLabelNode(text: order.description)
//        orderLabel.fontSize = 20
//        orderLabel.fontColor = .white
//        orderLabel.alpha = 1.0
//        orderLabel.position = CGPoint(x: 0, y: size.height / 2 + 5)
//        addChild(orderLabel)
        
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
    
    private func startCountdown() {
        waitingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.seconds -= 1
            
            if self.seconds <= 0 {
                onPatienceRunOut()
                timer.invalidate()
            } else {
                print("\(self.seconds) seconds left for customer")
            }
        }
        createTimerGuage(time: seconds)
    }
    
    private func served() {
        waitingTimer?.invalidate()
        waitingTimer = nil
    }
    
    deinit {
        waitingTimer?.invalidate()
    }
    
}

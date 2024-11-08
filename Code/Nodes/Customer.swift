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
    
    func orderSatisfied() {
        served()
        
        orderLabel.text = ""
        // TODO: Change status to eating and set timer
        self.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") }
    
    private func setupOrderLabel(size: CGSize) {
        orderLabel = SKLabelNode(text: order.description)
        orderLabel.fontSize = 20
        orderLabel.fontColor = .white
        orderLabel.alpha = 1.0
        orderLabel.position = CGPoint(x: 0, y: size.height / 2 + 5)
        addChild(orderLabel)
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
    }
    
    private func served() {
        waitingTimer?.invalidate()
        waitingTimer = nil
    }
    
    deinit {
        waitingTimer?.invalidate()
    }
    
}

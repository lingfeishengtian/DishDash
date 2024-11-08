//
//  Customer.swift
//  DishDash
//
//  Created by Kate Zheng on 11/7/24.
//
import SpriteKit

enum OrderType: String, CaseIterable{
    case rare = "RareSteak"
    case medium = "MediumSteak"
    case welldone = "WellDoneSteak"
}

class Customer: SKSpriteNode{
    var order: OrderType
    private var seconds: Int
    private var waitingTimer: Timer?
    
    private var orderLabel: SKLabelNode!
    
    
    init(order: OrderType, timeLimit: Int, size: CGSize) {
        self.order = order
        self.seconds = timeLimit
        let circle = SKShapeNode(circleOfRadius: size.width / 2)
        circle.fillColor = .orange
        let texture = SKView().texture(from: circle)!
        
        super.init(texture: texture, color: .clear, size: size)
        self.name = "Customer"
        
        setupOrderLabel(size: size)
        startCountdown()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") }
    
    private func setupOrderLabel(size: CGSize) {
        orderLabel = SKLabelNode(text: order.rawValue)
        orderLabel.fontSize = 12
        orderLabel.fontColor = .white
        orderLabel.position = CGPoint(x: 0, y: size.height / 2 + 5)
        addChild(orderLabel)
        }
    private func startCountdown() {
        waitingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                self.seconds -= 1
                
                if self.seconds <= 0 {
                    timer.invalidate()
                } else {
                    print("\(self.seconds) seconds left for customer")
                }
            }
        }
    func served() {
        waitingTimer?.invalidate()
        waitingTimer = nil
    }
    deinit {
        waitingTimer?.invalidate()
    }
}

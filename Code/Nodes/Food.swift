//
//  Food.swift
//  DishDash
//
//  Created by Kate Zheng on 11/2/24.
//
import SpriteKit

fileprivate var iterate: Int = 0

class Food: SKSpriteNode {
    var foodIdentifier: FoodItem
    var isIngredient: Bool
    var isFinalProduct: Bool
    var portion: Int? = nil
    private var cookingStage: Int = 0
    private var cookingTimer: Timer?
    
    init(name: FoodItem, size: CGSize, isIngredient: Bool = true, isFinalProduct: Bool = false) { //portion
        self.foodIdentifier = name
        self.isIngredient = isIngredient
        self.isFinalProduct = isFinalProduct
        let texture = SKTexture(imageNamed: name.assetName)
        
        super.init(texture: texture, color: .clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCooking() {
        if let (stoveOperation, resultingFoodItem) = Recipe.stoveOperation(for: foodIdentifier) {
            cookingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(stoveOperation.timeNeeded), repeats: false) { [weak self] _ in
                self?.updateFoodItem(foodItem: resultingFoodItem, shouldCook: true)
            }
        }
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
    
    func updateFoodItem(foodItem: FoodItem, shouldCook: Bool = false) { // update portion
        self.foodIdentifier = foodItem
        self.texture = SKTexture(imageNamed: foodItem.assetName)
        stopCooking()
        
        if shouldCook {
            startCooking()
        }
        
        if let portionCount = Recipe.portionNum(for: foodItem) {
            self.portion = portionCount
        } else {
            self.portion = nil
        }
    }
    
    func stopCooking() {
        cookingTimer?.invalidate()
        cookingTimer = nil
    }
    
    func sinkEvent() {
        let sinkOperation = Recipe.action(for: foodIdentifier)
        if sinkOperation?.action == .WaterFill {
            updateFoodItem(foodItem: sinkOperation!.result)
        }
    }
    
    func portionSingle() {
        if self.portion == nil {
            return
        }
        
        self.portion! -= 1
    }
}

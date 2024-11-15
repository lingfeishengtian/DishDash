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
    var portion: Int = 0
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
        
        let portionOp = Recipe.action(for:foodIdentifier)
        if let p = Recipe.portionNum(for: foodIdentifier), portionOp?.action == .Portion {
            self.portion = p
        }
        else {
            self.portion = 0
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
    // have portion counter, return new food, get rid of original food item
    //counter variable, no parameters and
    //if counter = 0 then remove from parent and remove references
    //detect if item is portionable and decrease counter when portioned in Gamescene
    func portionCounter() -> Food? {
        let portionOp = Recipe.action(for:foodIdentifier)
        if portionOp?.action == .Portion {
            let portionedFood = Food(name: portionOp!.result, size: .init(width: 50, height: 50))
            guard self.portion > 0 else { return nil }
            self.portion -= 1
            if self.portion == 0 {
                self.removeFromParent()
                return nil
            }
            return portionedFood
        }
        return nil
    }
    
}

//
//  Food.swift
//  DishDash
//
//  Created by Kate Zheng on 11/2/24.
//
import SpriteKit

fileprivate var iterate: Int = 0

class Food: DDEntity {
    var foodIdentifier: FoodItem
    var isIngredient: Bool
    var isFinalProduct: Bool
    var portion: Int? = nil{
        didSet {
            updatePortionLabel()
        }
    }
    private var cookingStage: Int = 0
    private var cookingTimer: Timer?
    private var portionLabel: SKLabelNode?
    
    /// When this item is reached, stop cooking
    var cookOverride: FoodItem?
    
    init(name: FoodItem, size: CGSize, isIngredient: Bool = true, isFinalProduct: Bool = false) { //portion
        self.foodIdentifier = name
        self.isIngredient = isIngredient
        self.isFinalProduct = isFinalProduct
        let texture = SKTexture(imageNamed: name.assetName)
        
        super.init(texture: texture, color: .clear, size: size)
        createPortionLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCooking() {
        if let (stoveOperation, resultingFoodItem) = Recipe.stoveOperation(for: foodIdentifier) {
            cookingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(stoveOperation.timeNeeded), repeats: false) { [weak self] _ in
                // Notify tutorial that food is cooked
                if let parent = self?.parent as? GameScene, let self {
                    parent.onAction(tutorialAction: .cook(self.foodIdentifier))
                }
                self?.updateFoodItem(foodItem: resultingFoodItem, shouldCook: self?.foodIdentifier != self?.cookOverride)
            }
            createTimerGuage(time: stoveOperation.timeNeeded)
        }
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
        
        // Update tutorial highlights
        if let parent = self.parent as? GameScene {
            parent.updateHighlights()
        }
    }
    
    func stopCooking() {
        removeTimerGuage()
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
        updatePortionLabel()
    }
    func createPortionLabel() {
        portionLabel = SKLabelNode(fontNamed: "Arial")
        portionLabel?.fontSize = 14
        portionLabel?.fontColor = .white
        portionLabel?.position = CGPoint(x: 0, y: -self.size.height / 2 - 20)
        portionLabel?.zPosition = 1
        addChild(portionLabel!)
    }
    
    func updatePortionLabel() {
        if let portionCount = portion {
            portionLabel?.text = "Portions: \(portionCount)"
            portionLabel?.isHidden = false
        } else {
            portionLabel?.isHidden = true
        }
    }
}

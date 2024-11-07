//
//  basicingredient.swift
//  DishDash
//
//  Created by Kate Zheng on 11/2/24.
//
import SpriteKit

let steakProgression = ["Steak", "SteakRare", "SteakMedium", "SteakBurnt"]
let steak = "Steak"
fileprivate var iterate: Int = 0

class Food: SKSpriteNode {
    var foodName: String
    var isIngredient: Bool
    var isFinalProduct: Bool
    private var cookingStage: Int = 0
    private var cookingTimer: Timer?

    init(name: String, size: CGSize, isIngredient: Bool = true, isFinalProduct: Bool = false) {
            self.foodName = name
            self.isIngredient = isIngredient
            self.isFinalProduct = isFinalProduct
            let texture = SKTexture(imageNamed: steak)
            
            super.init(texture: texture, color: .clear, size: size)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func startCooking() {
            if cookingStage < steakProgression.count - 1 {
                cookingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                    self?.advanceCookingStage()
                }
            }
        }
        
        private func advanceCookingStage() {
            if cookingStage < steakProgression.count - 1 {
                cookingStage += 1
                self.texture = SKTexture(imageNamed: steakProgression[cookingStage])
            } else {
                
                cookingTimer?.invalidate()
                cookingTimer = nil
            }
        }
        
        func stopCooking() {
            cookingTimer?.invalidate()
            cookingTimer = nil
        }
    }

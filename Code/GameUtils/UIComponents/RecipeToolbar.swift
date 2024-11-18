//
//  RecipeToolbar.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation
import SpriteKit
import SwiftUI

fileprivate let basex: CGFloat = 0
fileprivate let basey: CGFloat = 300

extension GameScene {
    private func tileMapMinY() -> CGFloat {
        return tileMap.frame.height / 2
    }
    
    private func tileMapMinX() -> CGFloat {
        return 0
    }
    
    func updateCurrentRecipeInstructions() {
        var generatedLabel = childNode(withName: "recipeLabel") as? SKLabelNode
        if generatedLabel == nil {
            generatedLabel = generateDefaultGameSceneLabel(text: "",
                                                           fontSize: 20,
                                                           position: CGPoint(x: tileMapMinX(), y: tileMapMinY())
            )
            generatedLabel?.name = "recipeLabel"
        }
        
        guard let generatedLabel = generatedLabel else { return }
        
        generatedLabel.removeFromParent()
        if let currentTutorialPhase {
            generatedLabel.text = currentTutorialPhase.description
            addChild(generatedLabel)
        }
    }
    
    func setupRecipeToolbar() {
        // book.fill
        let image = UIImage(systemName: "book.fill")!.withTintColor(.systemBlue)

        let data = image.pngData()
        let newImage = UIImage(data: data!)
        let texture = SKTexture(image: newImage!)
        
        let recipeToolbar = SKSpriteNode(texture: texture)
        recipeToolbar.position = CGPoint(x: basex + 150, y: basey + 50)
        recipeToolbar.zPosition = 10
        recipeToolbar.name = "RecipeBook"
        recipeToolbar.scale(to: CGSize(width: 50, height: 50))
        recipeToolbar.color = .systemBlue
        recipeToolbar.colorBlendFactor = 1
        addChild(recipeToolbar)
    }
}

struct RecipeInstructionView: View {
    let foodItem: [FoodItem]
    @Environment(\.colorScheme) var colorScheme
    
    func generateTutorialPhaseHStack(instruction: TutorialAction) -> HStack<some View> {
        HStack {
            switch instruction {
            case .combine(let food1, let food2), .grabSourceToFoodItem(let food1, let food2):
                Image(food1.assetName)
                    .spriteKitAsset()
                Text("+")
                    .font(.largeTitle)
                Image(food2.assetName)
                    .spriteKitAsset()
                Text("=")
                    .font(.largeTitle)
                Image(Recipe.combineIngredients(food1, food2)!.assetName)
                    .spriteKitAsset()
            case .action(let food, let tile), .grabSourceToTile(let food, let tile):
                Image(food.assetName)
                    .spriteKitAsset()
                Text("+")
                    .font(.largeTitle)
                Image(tile.assetName)
                    .spriteKitAsset()
                Text("=")
                    .font(.largeTitle)
                Image(tile.assetName)
                    .spriteKitAsset()
                    .overlay {
                        Image(food.assetName)
                            .spriteKitAsset()
                    }
            case .cook(let food):
                Image(TileType.machine.assetName)
                    .spriteKitAsset()
                    .overlay {
                        Image(food.assetName)
                            .spriteKitAsset()
                    }
                Text("+")
                Image(systemName: "flame.fill")
                    .foregroundStyle(.red)
                    .font(.largeTitle)
                Image(systemName: "clock.fill")
                    .font(.largeTitle)
                Text("=")
                Image(Recipe.stoveOperation(for: food)!.result.assetName)
                    .spriteKitAsset()
            case .serve(let food):
                Image(food.assetName)
                    .spriteKitAsset()
                Text("->")
                    .font(.largeTitle)
                Image(systemName: "figure.wave")
                    .font(.largeTitle)
            }
        }
    }
    
    var body: some View {
        VStack {
            TabView {
                ForEach(foodItem, id: \.self) { item in
                    VStack{
                        HStack {
                            Text(item.description)
                                .multilineTextAlignment(.leading)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding()
                                .padding(.horizontal)
                            Spacer()
                        }
                        ForEach(item.tutorialSequence) { instruction in
                            generateTutorialPhaseHStack(instruction: instruction)
                        }
                        Spacer()
                    }.frame(maxWidth: .infinity)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .onAppear() {
                if colorScheme == .light {
                    UIPageControl.appearance().currentPageIndicatorTintColor = .black
                    UIPageControl.appearance().pageIndicatorTintColor = .gray
                }
            }
        }
    }
}

extension Image {
    func spriteKitAsset() -> some View {
        self.resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
    }
}

#Preview {
    RecipeInstructionView(foodItem: FoodOrderCategory.Steak.orderableItems)
}

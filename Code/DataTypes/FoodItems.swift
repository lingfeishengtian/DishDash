//
//  FoodItems.swift
//  DishDash
//
//  All enums in this file are used to define food items and their properties
//  Even this code could be turned into a JSON file, it would lose the switch
//  case compiler case checking functionality that Swift provides.
//
//  Created by Hunter Han on 11/8/24.
//
import Foundation

enum FoodOrderCategory: Int, CaseIterable {
    case Steak = 0
    case Sushi = 1
    
    case All = 10
    
    var foodSources: [FoodItem] {
        switch self {
        case .Steak:
            return [.SteakRaw]
        case .Sushi:
            return [.WholeFish, .Rice, .Pot, .Knife]
        case .All:
            return FoodOrderCategory.allCases.flatMap { $0 == .All ? [] : $0.foodSources }
        }
    }
    
    var orderableItems: [FoodItem] {
        switch self {
        case .Steak:
            return [.SteakRare, .SteakMedium, .SteakBurnt]
        case .Sushi:
            return [.SlicedFish, .Nigiri]
        case .All:
            return FoodOrderCategory.allCases.flatMap { $0 == .All ? [] : $0.orderableItems }
        }
    }
    
    var tutorialSequence: [TutorialAction] {
        switch self {
        case .Steak:
            return [
                .action(.SteakRaw, .machine),
                .cook(.SteakRaw),
                .serve(.SteakRare),
                .action(.SteakRaw, .machine),
                .cook(.SteakRaw),
                .cook(.SteakRare),
                .serve(.SteakMedium),
                .action(.SteakRaw, .machine),
                .cook(.SteakRaw),
                .cook(.SteakRare),
                .cook(.SteakMedium),
                .serve(.SteakBurnt)
            ]
        case .Sushi:
            return [
                .grabSourceToTile(.WholeFish, .counter),
                .grabSourceToFoodItem(.Knife, .WholeFish),
                .serve(.SlicedFish),
                .grabSourceToTile(.WholeFish, .counter),
                .grabSourceToFoodItem(.Knife, .WholeFish),
                .grabSourceToTile(.Pot, .sink),
                .grabSourceToFoodItem(.Rice, .PotWater),
                .action(.PotRawRiceWater, .machine),
                .cook(.PotRawRiceWater),
                .combine(.PotCookedRice, .SlicedFish),
                .serve(.Nigiri)
            ]
        case .All:
            return FoodOrderCategory.allCases.flatMap { $0 == .All ? [] : $0.tutorialSequence }
        }
    }
    
    static func randomOrderableItem(for category: FoodOrderCategory) -> FoodItem {
        return category.orderableItems.randomElement()!
    }
}

enum FoodItem: Int, CaseIterable {
    /// Orderable Items have IDs < 1000
    case SteakRare = 0
    case SteakMedium = 1
    case SteakBurnt = 2 // Well Done for insane people thats my dad :(
    
    case SlicedFish = 3
    //case Sashimi = 4
    case Nigiri = 5
    
    /// Cooking Assets have 1000 <= ID < 5000
    case SteakRaw = 2000
    
    case Pot = 1000
    case PotWater = 1001
    case PotRawRice = 1002
    case PotRawRiceWater = 1003
    case PotCookedRice = 1004
    
    case Riceball = 1006
    case WholeFish = 1007
    case Rice = 1005
    
    /// Misc Items have IDs >= 5000
    case BurntBlock = 5000
    case Knife = 5001
    
    var assetName: String {
        switch self {
        case .SteakRaw:
            return "Steak"
        case .SteakRare:
            return "SteakRare"
        case .SteakMedium:
            return "SteakMedium"
        case .SteakBurnt:
            return "SteakBurnt"
        case .BurntBlock:
            return "BurntBlock"
        case .Pot:
            return "EmptyPot"
        case .PotWater:
            return "PotWater"
        case .PotRawRice:
            return "PotRawRice"
        case .PotRawRiceWater:
            return "PotRawRiceWater"
        case .PotCookedRice:
            return "PotCookedRice"
        case .Rice:
            return "RawRice"
        case .WholeFish:
            return "WholeFish"
        case .SlicedFish:
            return "SlicedFish"
//        case .Sashimi:
//            return "Sashimi"
        case .Nigiri:
            return "Nigiri"
        case .Knife:
            return "Knife"
        case .Riceball:
            return "Riceball"
        }
    }
    
    var description: String {
        switch self {
        case .SteakRaw:
            return "Raw Steak"
        case .SteakRare:
            return "Rare Steak"
        case .SteakMedium:
            return "Medium Steak"
        case .SteakBurnt:
            return "Well Done Steak"
        case .BurntBlock:
            return "Burnt Block"
        case .Pot:
            return "Pot"
        case .PotWater:
            return "Pot of Water"
        case .PotRawRice:
            return "Pot of Raw Rice"
        case .PotRawRiceWater:
            return "Pot of Raw Rice and Water"
        case .PotCookedRice:
            return "Pot of Cooked Rice"
        case .Rice:
            return "Raw Rice"
        case .WholeFish:
            return "Whole Fish"
        case .SlicedFish:
            return "Sliced Fish"
//        case .Sashimi:
//            return "Sashimi"
        case .Nigiri:
            return "Nigiri"
        case .Knife:
            return "Knife"
        case .Riceball:
            return "Riceball"
        }
    }
    
    var tutorialSequence: [TutorialAction] {
        switch self {
        case .SteakRare:
            return [
                .grabSourceToTile(.SteakRaw, .machine),
                .cook(.SteakRaw),
                .serve(.SteakRare)
            ]
        case .SteakMedium:
            return [
                .grabSourceToTile(.SteakRaw, .machine),
                .cook(.SteakRaw),
                .cook(.SteakRare),
                .serve(.SteakMedium)
            ]
        case .SteakBurnt:
            return [
                .grabSourceToTile(.SteakRaw, .machine),
                .cook(.SteakRaw),
                .cook(.SteakRare),
                .cook(.SteakMedium),
                .serve(.SteakBurnt)
            ]
        case .SlicedFish:
            return [
                .grabSourceToTile(.WholeFish, .counter),
                .grabSourceToFoodItem(.Knife, .WholeFish),
                .serve(.SlicedFish)
            ]
        case .Nigiri:
            return [
                .grabSourceToTile(.WholeFish, .counter),
                .grabSourceToFoodItem(.Knife, .WholeFish),
                .grabSourceToTile(.Pot, .sink),
                .grabSourceToFoodItem(.Rice, .PotWater),
                .action(.PotRawRiceWater, .machine),
                .cook(.PotRawRiceWater),
                .combine(.PotCookedRice, .SlicedFish),
                .serve(.Nigiri)
            ]
        default:
            return []
        }
    }
}

enum Action: Int {
    case Knead = 0
    case Mix = 1
    case Cut = 2
    case Puree = 3
    case Portion = 4
    
    
    case WaterFill = 20
    
    // TODO: timeNeeded
}

enum StoveOperation: Int {
    case CookShort = 0
    case CookMedium = 1
    case CookLong = 2
    case SlowCook = 3
    
    var timeNeeded: Int {
        switch self {
        case .CookShort:
            return 3
        case .CookMedium:
            return 5
        case .CookLong:
            return 7
        case .SlowCook:
            return 10
        }
    }
}




/// Recipes are a set of actions defined that takes in two ingredients and produces a final product
struct Recipe {
    static func stoveOperation(for foodItem: FoodItem) -> (operation: StoveOperation, result: FoodItem)? {
        switch foodItem {
        case .SteakRaw:
            return (.CookShort, .SteakRare)
        case .SteakRare:
            return (.CookShort, .SteakMedium)
        case .SteakMedium:
            return (.CookShort, .SteakBurnt)
        case .SteakBurnt:
            return (.CookMedium, .BurntBlock)
        case .PotRawRiceWater:
            return (.CookMedium, .PotCookedRice)
        default:
            return nil
        }
    }
    
    static func action(for foodItem: FoodItem) -> (action: Action, result: FoodItem)? {
        switch foodItem {
        case .Pot:
            return (.WaterFill, .PotWater)
        case .PotRawRice:
            return (.WaterFill, .PotRawRiceWater)
//        case .WholeFish:
//            return (.Cut, .SlicedFish)
//        case .SlicedFish:
//            return (.Portion, .Sashimi)
//        case .PotCookedRice:
//            return (.Portion, .Riceball)
        
        default:
            return nil
        }
    }
    
    // TODO: Implement any order
    static func combineIngredients(_ ingredient1: FoodItem, _ ingredient2: FoodItem) -> FoodItem? {
        let result = combineIngredientsInternal(ingredient1, ingredient2)
        let result2 = combineIngredientsInternal(ingredient2, ingredient1)
        
        return result ?? result2
    }
    
    private static func combineIngredientsInternal(_ ingredient1: FoodItem, _ ingredient2: FoodItem) -> FoodItem? {
        switch (ingredient1, ingredient2) {
        case (.PotWater, .Rice):
            return .PotRawRiceWater
        case (.Pot, .Rice):
            return .PotRawRice
        case (.SlicedFish, .PotCookedRice):
            return .Nigiri
        case (.Knife, .WholeFish):
            return .SlicedFish
        default:
            return nil
        }
    }
    
    static func portionNum(for portion: FoodItem) -> Int? {
        switch portion {
//        case .SlicedFish:
//            return 5
        case .PotCookedRice:
            return 5
        default:
            return nil
        }
    }
}

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

struct OrderableFoodRandomSelectionOptions: OptionSet {
    let rawValue: Int
    
    static let steak = OrderableFoodRandomSelectionOptions(rawValue: 1 << 0)
    static let sushi = OrderableFoodRandomSelectionOptions(rawValue: 1 << 1)
    
    static let all = [steak, sushi]
    
    func idRange() -> ClosedRange<Int> {
        switch self {
        case .steak:
            return 0...2
        case .sushi:
            return 1003...1007
        default:
            return 0...999
        }
    }
}

enum FoodItem: Int, CaseIterable {
    /// Orderable Items have IDs < 1000
    case SteakRaw = 2000
    case SteakRare = 0
    case SteakMedium = 1
    case SteakBurnt = 2 // Well Done for insane people thats my dad :(
    
    /// Cooking Assets have 1000 <= ID < 5000
    case Pot = 1000
    case PotWater = 1001
    case PotRawRice = 1002
    case PotRawRiceWater = 1003
    case PotCookedRice = 1004
    
    case Rice = 1005
    
    case WholeFish = 1006
    case SlicedFish = 1007
    
    /// Misc Items have IDs >= 5000
    case BurntBlock = 5000
    
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
            return "WholeFish"
        case .SlicedFish:
            return "SlicedFish"
        }
    }
    
    static func randomOrderableItem(options: OrderableFoodRandomSelectionOptions = .steak) -> FoodItem {
        var orderableItems = [FoodItem]()
        
        for item in FoodItem.allCases where
//        item.rawValue < 1000 &&
        options.idRange().contains(item.rawValue) {
            orderableItems.append(item)
        }
        
        return orderableItems.randomElement()!
    }
}

enum Action: Int {
    case Knead = 0
    case Mix = 1
    case Cut = 2
    case Puree = 3
    
    
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
        case .WholeFish:
            return (.Cut, .SlicedFish)
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
        default:
            return nil
        }
    }
}

//combining items makes original items inivisble
//need to hold to cut instead of tapping and waiting

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

enum FoodItem: Int, CaseIterable {
    /// Orderable Items have IDs < 1000
    case SteakRare = 0
    case SteakMedium = 1
    case SteakBurnt = 2 // Well Done for insane people
    
    /// Source Items have 1000 <= ID < 5000
    case SteakRaw = 1000
    
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
        }
    }
    
    static func randomOrderableItem() -> FoodItem {
        var orderableItems = [FoodItem]()
        
        for item in FoodItem.allCases where item.rawValue < 1000 {
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
        default:
            return nil
        }
    }
}

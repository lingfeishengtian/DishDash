//
//  TileType.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation
import UIKit

enum TileType: String, CaseIterable {
    case counter = "Counter"
    case machine = "Machine"
    case floor = "Floor"
    case table = "Table"
    case sink = "Sink"
    case trashcan = "Trashcan"
    case unknown = "Unknown"
    
    var color: UIColor {
        switch self {
        case .counter:
            return .gray
        case .machine:
            return .blue
        case .floor:
            return .white
        case .table:
            return .brown
        case .sink:
            return .cyan
        case .trashcan:
            return .red
        case .unknown:
            return .black
        }
    }
    
    var placeable: Bool {
        switch self {
        case .counter, .machine, .table, .sink, .trashcan:
            return true
        case .floor, .unknown:
            return false
        }
    }
}

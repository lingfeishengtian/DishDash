//
//  TilePoint.swift
//  DishDash
//
//  Created by Hunter Han on 11/16/24.
//

import Foundation

struct TilePoint: Hashable {
    let x: Int
    let y: Int
    
    @available(*, deprecated, message: "Use init(column:row:) instead")
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init(column: Int, row: Int) {
        self.x = column
        self.y = row
    }
    
    var column: Int { x }
    var row: Int { y }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

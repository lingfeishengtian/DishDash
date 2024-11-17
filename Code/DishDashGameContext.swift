//
//  DishDashGameContext.swift
//  DishDash
//
//  Created by Hunter Han on 11/6/24.
//

import Foundation
import SpriteKit
import SwiftUI

class DishDashGameContext: GameContext {
    let shouldBeginTutorial: Bool = true
    
    override init(dependencies deps: Dependencies) {
        super.init(dependencies: deps)
        scene = GameScene(gameContext: self, shouldBeginTutorial: shouldBeginTutorial)
    }
}

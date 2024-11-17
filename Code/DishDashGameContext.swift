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
    override init(dependencies deps: Dependencies) {
        super.init(dependencies: deps)
        scene = GameScene(fileNamed: "GameScene")!
        (scene?.scene as? GameScene)?.gameContext = self
    }
}

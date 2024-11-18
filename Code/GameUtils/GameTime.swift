//
//  GameTime.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation

extension GameScene {
    func pauseGame() {
        customerGeneratorTimer?.pause()
        for child in children {
            if let ddEntity = child as? DDEntity {
                ddEntity.pauseTimer()
            }
        }
    }
    
    func resumeGame() {
        if !inTutorialPhase {
            customerGeneratorTimer?.resume()
        }
        for child in children {
            if let ddEntity = child as? DDEntity {
                ddEntity.resumeTimer()
            }
        }
    }
}

//
//  ContentVie.swift
//  DishDash
//
//  Created by Hunter Han on 11/4/24.
//

import GameplayKit
import SpriteKit
import SwiftUI

struct ContentView: View {
    let context = GameContext(dependencies: .init())

    var body: some View {
        ZStack {
            SpriteView(scene: GKScene(fileNamed: "GameScene")?.rootNode as! GameScene, debugOptions: [])
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
        }
        .statusBarHidden()
    }
}

#Preview {
    ContentView()
}

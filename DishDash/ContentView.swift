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
    let context = DishDashGameContext(dependencies: .init())

    var body: some View {
        ZStack {
            SpriteView(scene: context.scene!, debugOptions: [])
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
        }
        .statusBarHidden()
    }
}

#Preview {
    ContentView()
}

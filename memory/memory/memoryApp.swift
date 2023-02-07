//
//  memoryApp.swift
//  memory
//
//  Created by 张裕阳 on 2022/8/13.
//

import SwiftUI

@main
struct memoryApp: App {
    let game = emojiMemoryGame()
    
    var body: some Scene {
        WindowGroup {
            memoryGameView(game: game)
        }
    }
}

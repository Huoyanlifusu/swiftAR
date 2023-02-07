//
//  EmojiMemoryGame.swift
//  memory
//
//  Created by 张裕阳 on 2022/8/15.
//

import SwiftUI

class emojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    static let emojis = ["🚗", "🚕", "🚙", "🚌", "🏎", "🚓", "🚑", "🚜", "🚛", "🚝", "🚄", "🦽"]
    
    static func createMemoryGame() -> MemoryGame<String> {
        MemoryGame<String>(TheNumberOfCards: 4){ index in
            emojiMemoryGame.emojis[index] }
    }
    
    @Published private var model = createMemoryGame()
    
    var cards: Array<Card> {
        return model.cards
    }
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    func restart() {
        model = emojiMemoryGame.createMemoryGame()
    }
}


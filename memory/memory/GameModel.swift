//
//  GameModel.swift
//  memory
//
//  Created by 张裕阳 on 2022/8/15.
//

import Foundation


struct MemoryGame<cardContent> where cardContent: Equatable {
    struct Card: Identifiable {
        var isFaceUp = false
        var isMatched = false
        let content: cardContent
        let id: Int
    }
    
    private var indexOfOnlyFaceUpCard: Int? {
        get { cards.indices.filter({ cards[$0].isFaceUp }).OnlyAndOne
        }
        set { cards.indices.forEach{ cards[$0].isFaceUp = ($0 == newValue) }
        }
    }
    
    private(set) var cards: Array<Card>
    
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched
        {
            if let potentialIndex = indexOfOnlyFaceUpCard {
                if cards[potentialIndex].content == cards[chosenIndex].content {
                        cards[potentialIndex].isMatched = true
                        cards[chosenIndex].isMatched = true
                    }
                cards[chosenIndex].isFaceUp = true
            } else {
                indexOfOnlyFaceUpCard = chosenIndex
            }
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    init(TheNumberOfCards: Int, createCardContent: (Int) -> cardContent) {
        cards = []
        // add numberofcards * 2 cards in the array
        for pairIndex in 0..<TheNumberOfCards {
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
        cards.shuffle()
    }
}

extension Array {
    var OnlyAndOne: Element? {
        if count == 1 {
            return first
        } else {
            return nil
        }
    }
}

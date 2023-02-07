//
//  memoryGameView.swift
//  memory
//
//  Created by 张裕阳 on 2022/8/13.
//

import SwiftUI

struct memoryGameView: View {
    @ObservedObject var game: emojiMemoryGame
    @Namespace private var dealingNameSpace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                gameBody
                HStack {
                    restart
                    Spacer()
                    shuffle
                }
                .padding(.horizontal)
            }
            deckBody
        }
        .padding()
    }
    
    @State private var dealt = Set<Int>()
    
    private func deal(_ card: emojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUnDealt(_ card: emojiMemoryGame.Card) -> Bool {
        return !dealt.contains(card.id)
    }
    
    private func dealDelay (_ card: emojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * (GameConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: GameConstants.dealDuration).delay(delay)
    }
    
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: 2/3, content: { card in
            cardView(for: card)
        })
        .padding(.horizontal)
    }
    
    var shuffle: some View {
        Button("shuffle") {
            withAnimation(.easeInOut) {
                game.shuffle()
            }
        }
    }
    
    var restart: some View  {
        Button("restart") {
            withAnimation(.easeInOut) {
                dealt = []
                game.restart()
            }
        }
    }
    
    private func zIndex(of card: emojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: {$0.id == card.id }) ?? 0)
    }
    
    @ViewBuilder
    private func cardView(for card: emojiMemoryGame.Card) -> some View {
        if isUnDealt(card) || (card.isMatched && !card.isFaceUp) {
            Rectangle().opacity(0)
        } else {
            Cardview(card)
                .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
                .padding(3)
                .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale).animation(.easeInOut(duration: 1)))
                .zIndex(zIndex(of: card))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 1)) {
                        game.choose(card)
                    }
                }
        }
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUnDealt)) {
                card in Cardview(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity).animation(.easeInOut(duration: 1)))
            }
            .frame(width: GameConstants.undealtWidth, height: GameConstants.undealtHeight)
            .foregroundColor(GameConstants.color)
            .onTapGesture {
                // deal cards
                for card in game.cards {
                    withAnimation(dealDelay(card)) {
                        deal(card)
                    }
                }
            }
        }
    }
    
    private struct GameConstants {
        static let undealtHeight: CGFloat = 90
        static let aspectRatio: CGFloat = 2/3
        static let undealtWidth: CGFloat = undealtHeight * aspectRatio
        static let color = Color.red
        static let dealDuration: Double = 1
        static let totalDealDuration: Double = 5
    }
}

struct Cardview: View {
    private let card: emojiMemoryGame.Card
    
    init(_ card: emojiMemoryGame.Card) {
        self.card = card
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: 110-90))
                    .padding(5).opacity(0.5)
                    .foregroundColor(.blue)
                Text(card.content).font(font(in: geometry.size))
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(card.isFaceUp)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private func font(in size: CGSize) -> Font {
        return Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.45
        static let fontSize: CGFloat = 32
    }
}





























struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = emojiMemoryGame()
        return memoryGameView(game: game)
    }
}

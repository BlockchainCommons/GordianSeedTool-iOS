//
//  PlayingCardKeypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

struct PlayingCardKeypad: View, Keypad {
    @Binding var isEmpty: Bool
    var append: (PlayingCard) -> Void
    var removeLast: () -> Void

    @State var selectedRank: PlayingCard.Rank?
    @State var selectedSuit: PlayingCard.Suit?

    private func sync() {
        guard let rank = selectedRank, let suit = selectedSuit else { return }
        append(PlayingCard(rank: rank, suit: suit))
        selectedRank = nil
        selectedSuit = nil
    }

    private func buttonFor(rank: PlayingCard.Rank, key: KeyEquivalent) -> KeypadButton<PlayingCard.Rank> {
        KeypadButton(value: rank, selectedValue: $selectedRank, string: rank.string, key: key)
    }

    private func buttonFor(suit: PlayingCard.Suit, key: KeyEquivalent) -> KeypadButton<PlayingCard.Suit> {
        KeypadButton(value: suit, selectedValue: $selectedSuit, imageName: suit.imageName, color: suit.color, key: key)
    }

    var body: some View {
        VStack {
            HStack {
                buttonFor(rank: .ace, key: "a")
                buttonFor(rank: .two, key: "2")
                buttonFor(rank: .three, key: "3")
                buttonFor(rank: .four, key: "4")
                buttonFor(rank: .five, key: "5")
            }
            HStack {
                buttonFor(rank: .six, key: "6")
                buttonFor(rank: .seven, key: "7")
                buttonFor(rank: .eight, key: "8")
                buttonFor(rank: .nine, key: "9")
                buttonFor(rank: .ten, key: "t")
            }
            HStack {
                buttonFor(rank: .jack, key: "j")
                buttonFor(rank: .queen, key: "q")
                buttonFor(rank: .king, key: "k")
            }
            .padding(.bottom, 10)
            HStack {
                buttonFor(suit: .hearts, key: "h")
                buttonFor(suit: .spades, key: "s")
                buttonFor(suit: .diamonds, key: "d")
                buttonFor(suit: .clubs, key: "c")
            }
            .padding(.bottom, 10)
            HStack {
                KeypadDeleteButton(isEmpty: $isEmpty) { removeLast() }
            }
        }
        .onChange(of: selectedRank) { _ in
            self.sync()
        }
        .onChange(of: selectedSuit) { _ in
            self.sync()
        }
    }
}

struct PlayingCardKeypad_Previews: PreviewProvider {
    static var previews: some View {
        PlayingCardKeypad(isEmpty: Binding<Bool>.constant(false)) { _ in } removeLast: { }
        .preferredColorScheme(.dark)
        .padding(20)
        .previewLayout(.sizeThatFits)
    }
}

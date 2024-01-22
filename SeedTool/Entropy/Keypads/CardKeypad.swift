//
//  CardKeypad.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

struct CardKeypad: View, Keypad {
    typealias TokenType = CardToken

    @ObservedObject var model: EntropyViewModel<CardKeypad>

    static let name: String = "Playing Cards"
    static let entropyBitsPerValue: Double = log2(52)
    static let setsCreationDate = true
    @State var selectedRanks: [Card.Rank] = []
    @State var selectedSuits: [Card.Suit] = []

    init(model: EntropyViewModel<CardKeypad>) {
        self.model = model
    }

    private func sync() {
        guard !selectedRanks.isEmpty, !selectedSuits.isEmpty else { return }
        model.appendValue(CardToken(rank: selectedRanks.first!, suit: selectedSuits.first!))
        selectedRanks.removeAll()
        selectedSuits.removeAll()
    }

    private func buttonFor(rank: Card.Rank, key: KeyEquivalent) -> KeypadButton<Card.Rank> {
        KeypadButton(value: rank, selectedValues: $selectedRanks, string: rank.string, key: key, accessibilityLabel: rank.accessibilityLabel)
    }

    private func buttonFor(suit: Card.Suit, key: KeyEquivalent) -> KeypadButton<Card.Suit> {
        KeypadButton(value: suit, selectedValues: $selectedSuits, label: Image.cardSuit(suit), color: suit.color, key: key, accessibilityLabel: suit.accessibilityLabel)
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
            KeypadFunctionButtons(model: model) {
                selectedRanks.removeAll()
                selectedSuits.removeAll()
            }
        }
        .onChange(of: selectedRanks) { _ in
            self.sync()
        }
        .onChange(of: selectedSuits) { _ in
            self.sync()
        }
    }
}

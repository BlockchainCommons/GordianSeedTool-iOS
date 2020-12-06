//
//  PlayingCardKeypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI
import WolfSwiftUI

let regularFont: Font = Font.custom("HelveticaNeue-Bold", size: 48)
let condensedFont: Font = Font.custom("HelveticaNeue-CondensedBold", size: 48)

struct EntropyKey<T: Equatable>: View {
    let value: T
    @Binding var selectedValue: T?
    let label: AnyView

    @State private var isPressed: Bool = false

    var fillColor: Color {
        if isPressed {
            return .primary
        } else {
            return value == selectedValue ? Color.blue : Color.secondary
        }
    }

    var body: some View {
        label
            .padding(5)
            .frame(width: 60, height: 60)
            .background(Rectangle().fill(fillColor).cornerRadius(10).opacity(0.6))
            .onTouchEvent {
                isPressed = $0
                if !isPressed {
                    selectedValue = value
                }
            }
    }
}

struct PlayingCardKeypad: View {
    let nextValue: (PlayingCard) -> Void

    @State var selectedRank: PlayingCard.Rank?
    @State var selectedSuit: PlayingCard.Suit?

    private func sync() {
        guard let rank = selectedRank, let suit = selectedSuit else { return }
        nextValue(PlayingCard(rank: rank, suit: suit))
        selectedRank = nil
        selectedSuit = nil
    }

    private func font(for string: String) -> Font {
        string.count > 1 ? condensedFont : regularFont
    }

    private func label(for string: String) -> AnyView {
        return AnyView(
            Text(string)
                .font(font(for: string))
                .minimumScaleFactor(0.5)
        )
    }

    private func label(imageName: String, color: Color) -> AnyView {
        AnyView(
            Image(systemName: imageName)
                .resizable()
                .foregroundColor(color)
                .aspectRatio(1, contentMode: .fit)
                .padding(5)
        )
    }

    private func label(for rank: PlayingCard.Rank) -> AnyView {
        label(for: rank.string)
    }

    private func label(for suit: PlayingCard.Suit) -> AnyView {
        label(imageName: suit.imageName, color: suit.color)
    }

    private func keyFor(rank: PlayingCard.Rank) -> EntropyKey<PlayingCard.Rank> {
        EntropyKey(value: rank, selectedValue: $selectedRank, label: label(for: rank))
    }

    private func keyFor(suit: PlayingCard.Suit) -> EntropyKey<PlayingCard.Suit> {
        EntropyKey(value: suit, selectedValue: $selectedSuit, label: label(for: suit))
    }

    var body: some View {
        VStack {
            HStack {
                keyFor(rank: .ace)
                keyFor(rank: .two)
                keyFor(rank: .three)
                keyFor(rank: .four)
                keyFor(rank: .five)
            }
            HStack {
                keyFor(rank: .six)
                keyFor(rank: .seven)
                keyFor(rank: .eight)
                keyFor(rank: .nine)
                keyFor(rank: .ten)
            }
            HStack {
                keyFor(rank: .jack)
                keyFor(rank: .queen)
                keyFor(rank: .king)
            }
            HStack {
                keyFor(suit: .hearts)
                keyFor(suit: .spades)
                keyFor(suit: .diamonds)
                keyFor(suit: .clubs)
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

struct EntropyKeys_Previews: PreviewProvider {
    static var previews: some View {
        PlayingCardKeypad() {
            print($0)
        }
        .preferredColorScheme(.dark)
        .padding(20)
        .previewLayout(.sizeThatFits)
    }
}

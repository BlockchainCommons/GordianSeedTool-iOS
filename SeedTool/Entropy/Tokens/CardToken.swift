//
//  PlayingCard.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI
import WolfBase

final class CardToken: Token {
    let id: UUID = UUID()
    let value: Card

    init(value: Card) {
        self.value = value
    }

    convenience init(rank: Card.Rank, suit: Card.Suit) {
        self.init(value: Card(rank: rank, suit: suit))
    }
}

extension CardToken: Randomizable {
    static func random<T>(using generator: inout T) -> CardToken where T : RandomNumberGenerator {
        let rank = Card.Rank(rawValue: Int.random(in: 0..<Card.Rank.allCases.count))!
        let suit = Card.Suit(rawValue: Int.random(in: 0..<Card.Suit.allCases.count))!
        return CardToken(value: Card(rank: rank, suit: suit))
    }
}

extension CardToken: TokenViewable {
    static var minimumWidth: CGFloat { 55 }
    private static var fontSize: CGFloat { 18 }

    static func font(for string: String) -> Font {
        string.count > 1 ? condensedFont(size: Self.fontSize) : regularFont(size: Self.fontSize)
    }

    var view: AnyView {
        HStack(spacing: 2) {
            Group {
                Text(value.rank.description)
                Image(systemName: value.suit.imageName)
                    .foregroundColor(value.suit.color)
            }
            .font(Self.font(for: value.rank.description))
        }
        .tokenStyle()
        .eraseToAnyView()
    }
}

extension CardToken: StringTransformable {
    static func values(from string: String) -> [CardToken]? {
        guard string.count.isMultiple(of: 2) else { return nil }
        let s = Array(string).chunked(into: 2)
        var result: [CardToken] = []
        for c in s {
            guard let rank = rank(for: c[0]) else { return nil }
            guard let suit = suit(for: c[1]) else { return nil }
            result.append(CardToken(rank: rank, suit: suit))
        }
        return result
    }

    static func string(from values: [CardToken]) -> String {
        let c: [String] = values.map {
            String([character(for: $0.value.rank), character(for: $0.value.suit)])
        }
        return c.joined()
    }

    static func rank(for c: Character) -> Card.Rank? {
        switch c {
        case "a":
            return .ace
        case "2":
            return .two
        case "3":
            return .three
        case "4":
            return .four
        case "5":
            return .five
        case "6":
            return .six
        case "7":
            return .seven
        case "8":
            return .eight
        case "9":
            return .nine
        case "t":
            return .ten
        case "j":
            return .jack
        case "q":
            return .queen
        case "k":
            return .king
        default:
            return nil
        }
    }

    static func suit(for c: Character) -> Card.Suit? {
        switch c {
        case "s":
            return .spades
        case "c":
            return .clubs
        case "h":
            return .hearts
        case "d":
            return .diamonds
        default:
            return nil
        }
    }

    static func character(for rank: Card.Rank) -> Character {
        switch rank {
        case .ace:
            return "a"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .ten:
            return "t"
        case .jack:
            return "j"
        case .queen:
            return "q"
        case .king:
            return "k"
        }
    }

    static func character(for suit: Card.Suit) -> Character {
        switch suit {
        case .spades:
            return "s"
        case .clubs:
            return "c"
        case .hearts:
            return "h"
        case .diamonds:
            return "d"
        }
    }
}

extension CardToken: SeedProducer {
    static func seed(values: [CardToken]) -> Data {
        let entropy = Data(values.map { UInt8($0.value.index) })
        return deterministicRandom(entropy: entropy, count: 16)
    }
}

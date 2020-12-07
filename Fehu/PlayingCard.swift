//
//  PlayingCard.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

final class PlayingCard: Equatable, Identifiable {
    let id: UUID = UUID()
    let rank: Rank
    let suit: Suit

    static func == (lhs: PlayingCard, rhs: PlayingCard) -> Bool {
        lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }

    init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
    }

    enum Suit: Equatable, CustomStringConvertible {
        case spades
        case hearts
        case clubs
        case diamonds

        var color: Color {
            switch self {
            case .spades:
                return .black
            case .hearts:
                return .red
            case .clubs:
                return .black
            case .diamonds:
                return .red
            }
        }

        var imageName: String {
            switch self {
            case .spades:
                return "suit.spade.fill"
            case .hearts:
                return "suit.heart.fill"
            case .clubs:
                return "suit.club.fill"
            case .diamonds:
                return "suit.diamond.fill"
            }
        }

        var description: String {
            switch self {
            case .spades:
                return "♠️"
            case .hearts:
                return "♥️"
            case .clubs:
                return "♣️"
            case .diamonds:
                return "♦️"
            }
        }
    }

    enum Rank: Equatable, CustomStringConvertible {
        case ace
        case two
        case three
        case four
        case five
        case six
        case seven
        case eight
        case nine
        case ten
        case jack
        case queen
        case king

        var string: String {
            switch self {
            case .ace:
                return "A"
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
                return "10"
            case .jack:
                return "J"
            case .queen:
                return "Q"
            case .king:
                return "K"
            }
        }

        var description: String {
            string
        }
    }
}

extension PlayingCard: CustomStringConvertible {
    var description: String {
        "\(rank)\(suit)"
    }
}

extension PlayingCard: ValueViewable {
    static var minimumWidth: CGFloat { 55 }
    private static var fontSize: CGFloat { 18 }

    static func font(for string: String) -> Font {
        string.count > 1 ? condensedFont(size: Self.fontSize) : regularFont(size: Self.fontSize)
    }

    var view: AnyView {
        let v = HStack(spacing: 2) {
            Group {
                Text(rank.description)
                Image(systemName: suit.imageName)
                    .foregroundColor(suit.color)
            }
            .font(Self.font(for: rank.description))
        }
        .padding(5)
        .background(Color.gray.opacity(0.7))
        .cornerRadius(5)
        return AnyView(v)
    }

    private static func rank(for c: Character) -> Rank? {
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

    private static func suit(for c: Character) -> Suit? {
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

    private static func character(for rank: Rank) -> Character {
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

    private static func character(for suit: Suit) -> Character {
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

    static func values(from string: String) -> [PlayingCard]? {
        guard string.count.isMultiple(of: 2) else { return nil }
        let s = Array(string).chunked(into: 2)
        var result: [PlayingCard] = []
        for c in s {
            guard let rank = rank(for: c[0]) else { return nil }
            guard let suit = suit(for: c[1]) else { return nil }
            result.append(PlayingCard(rank: rank, suit: suit))
        }
        return result
    }

    static func string(from values: [PlayingCard]) -> String {
        let c: [String] = values.map {
            String([character(for: $0.rank), character(for: $0.suit)])
        }
        return c.joined()
    }
}

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
}

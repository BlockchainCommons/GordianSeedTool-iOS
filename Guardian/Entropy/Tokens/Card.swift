//
//  Card.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/8/20.
//

import SwiftUI

struct Card: Equatable {
    let rank: Rank
    let suit: Suit

    var index: Int {
        suit.rawValue * 13 + rank.rawValue
    }

    enum Suit: Int, Equatable, CustomStringConvertible, CaseIterable {
        case clubs
        case diamonds
        case hearts
        case spades

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

    enum Rank: Int, Equatable, CustomStringConvertible, CaseIterable {
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

extension Card: CustomStringConvertible {
    var description: String {
        "\(rank)\(suit)"
    }
}

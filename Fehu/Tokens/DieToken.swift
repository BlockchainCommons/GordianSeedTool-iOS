//
//  DieToken.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

final class DieToken: Token {
    let id: UUID = UUID()
    let value: Int

    init(value: Int) {
        self.value = value
    }
}

extension DieToken: Randomizable {
    static func random<T>(using generator: inout T) -> DieToken where T : RandomNumberGenerator {
        DieToken(value: Int.random(in: 1...6))
    }
}

extension DieToken: ValueViewable {
    static var minimumWidth: CGFloat { 20 }

    var view: AnyView {
        AnyView(
            Text(value.description)
            .font(regularFont(size: 18))
            .padding(5)
            .background(Color.gray.opacity(0.7))
            .cornerRadius(5)
        )
    }
}

extension DieToken: StringTransformable {
    static func values(from string: String) -> [DieToken]? {
        var result: [DieToken] = []
        for c in string {
            switch c {
            case "1":
                result.append(DieToken(value: 1))
            case "2":
                result.append(DieToken(value: 2))
            case "3":
                result.append(DieToken(value: 3))
            case "4":
                result.append(DieToken(value: 4))
            case "5":
                result.append(DieToken(value: 5))
            case "6":
                result.append(DieToken(value: 6))
            default:
                return nil
            }
        }
        return result
    }

    static func string(from values: [DieToken]) -> String {
        let characters: [Character] = values.map { dieRoll in
            switch dieRoll.value {
            case 1:
                return "1"
            case 2:
                return "2"
            case 3:
                return "3"
            case 4:
                return "4"
            case 5:
                return "5"
            case 6:
                return "6"
            default:
                fatalError()
            }
        }
        return String(characters)
    }
}

//
//  DieRoll.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

final class DieRoll: Roll {
    let id: UUID = UUID()
    let value: Int

    init(value: Int) {
        self.value = value
    }

    static func random<T>(using generator: inout T) -> DieRoll where T : RandomNumberGenerator {
        DieRoll(value: Int.random(in: 1...6))
    }
}

extension DieRoll: ValueViewable {
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

    static func values(from string: String) -> [DieRoll]? {
        var result: [DieRoll] = []
        for c in string {
            switch c {
            case "1":
                result.append(DieRoll(value: 1))
            case "2":
                result.append(DieRoll(value: 2))
            case "3":
                result.append(DieRoll(value: 3))
            case "4":
                result.append(DieRoll(value: 4))
            case "5":
                result.append(DieRoll(value: 5))
            case "6":
                result.append(DieRoll(value: 6))
            default:
                return nil
            }
        }
        return result
    }

    static func string(from values: [DieRoll]) -> String {
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

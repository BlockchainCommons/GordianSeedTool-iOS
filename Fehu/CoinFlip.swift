//
//  CoinFlip.swift
//  Fehu
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

final class CoinFlip: Equatable, Identifiable {
    let id: UUID = UUID()
    let value: Bool

    static func == (lhs: CoinFlip, rhs: CoinFlip) -> Bool {
        lhs.value == rhs.value
    }

    init(value: Bool) {
        self.value = value
    }
}

extension CoinFlip: ValueViewable {
    static var minimumWidth: CGFloat { 30 }

    static func symbol(for value: Bool) -> String {
        value ? "🅗" : "Ⓣ"
    }

    var view: AnyView {
        AnyView(
            Text(Self.symbol(for: value))
            .font(regularFont(size: 18))
            .padding(5)
            .background(Color.gray.opacity(0.7))
            .cornerRadius(5)
        )
    }

    static func values(from string: String) -> [CoinFlip]? {
        var result: [CoinFlip] = []
        for c in string {
            switch c {
            case "1":
                result.append(CoinFlip(value: true))
            case "0":
                result.append(CoinFlip(value: false))
            default:
                return nil
            }
        }
        return result
    }

    static func string(from values: [CoinFlip]) -> String {
        String(values.map { $0.value ? Character("1") : Character("0") })
    }
}

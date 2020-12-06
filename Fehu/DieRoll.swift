//
//  DieRoll.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

final class DieRoll: Equatable, Identifiable {
    let id: UUID = UUID()
    let value: Int

    static func == (lhs: DieRoll, rhs: DieRoll) -> Bool {
        lhs.value == rhs.value
    }

    init(value: Int) {
        self.value = value
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
}

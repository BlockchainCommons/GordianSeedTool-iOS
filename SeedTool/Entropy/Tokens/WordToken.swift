//
//  WordToken.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation

final class WordToken: Token {
    let id: UUID = UUID()
    let value: String

    init(value: String) {
        self.value = value
    }
}

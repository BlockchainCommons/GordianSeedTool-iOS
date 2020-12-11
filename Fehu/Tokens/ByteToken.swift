//
//  ByteToken.swift
//  Fehu
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

final class ByteToken: Token {
    let id: UUID = UUID()
    let value: UInt8

    init(value: UInt8) {
        self.value = value
    }

    convenience init(highDigit: Int, lowDigit: Int) {
        self.init(value: UInt8((highDigit & 0xf) << 4) | UInt8(lowDigit & 0xf))
    }
}

extension ByteToken: Randomizable {
    static func random<T>(using generator: inout T) -> ByteToken where T : RandomNumberGenerator {
        ByteToken(value: UInt8.random(in: 0...255))
    }
}

extension ByteToken: ValueViewable {
    static var minimumWidth: CGFloat { 40 }

    var view: AnyView {
        Text(String(format: "%02X", value))
            .font(regularFont(size: 18))
            .tokenStyle()
            .eraseToAnyView()
    }
}

extension ByteToken: StringTransformable {
    static func values(from string: String) -> [ByteToken]? {
        guard let data = Data(hex: string) else { return nil }
        return data.map { ByteToken(value: $0) }
    }

    static func string(from values: [ByteToken]) -> String {
        Data(values.map { $0.value }).hex
    }
}

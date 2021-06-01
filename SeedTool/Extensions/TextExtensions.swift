//
//  TextExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/4/21.
//

import SwiftUI

extension Text {
    func monospaced() -> Text {
        font(.system(.body, design: .monospaced))
    }
    
    func monospaced(size: CGFloat, weight: Font.Weight = .regular) -> Text {
        font(.system(size: size, weight: weight, design: .monospaced))
    }
}

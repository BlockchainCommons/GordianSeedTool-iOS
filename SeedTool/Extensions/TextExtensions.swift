//
//  TextExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/4/21.
//

import SwiftUI

extension Text {
    func monospaced(weight: Font.Weight = .regular) -> Text {
        font(.system(.body, design: .monospaced).weight(weight))
    }
    
    func monospaced(size: CGFloat, weight: Font.Weight = .regular) -> Text {
        font(.system(size: size, weight: weight, design: .monospaced))
    }
}

//
//  TextExtensions.swift
//  Guardian
//
//  Created by Wolf McNally on 2/4/21.
//

import SwiftUI

extension Text {
    func monospaced() -> Text {
        font(.system(.body, design: .monospaced))
    }
}

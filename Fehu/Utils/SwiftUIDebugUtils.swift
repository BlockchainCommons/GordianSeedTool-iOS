//
//  SwiftUIDebugUtils.swift
//  Guardian
//
//  Created by Wolf McNally on 1/25/21.
//

import SwiftUI

extension View {
    func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") -> some View {
        #if DEBUG
        let output = items.map { "*\($0)" }.joined(separator: separator)
        print(output, terminator: terminator)
        #endif
        return self
    }
}

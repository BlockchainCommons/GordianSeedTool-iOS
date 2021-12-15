//
//  TokenStyle.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/11/20.
//

import SwiftUI

struct TokenStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(5)
            .background(Color.gray.opacity(0.7))
            .cornerRadius(5)
    }
}

extension View {
    func tokenStyle() -> some View {
        modifier(TokenStyle())
    }
}

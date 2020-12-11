//
//  FieldStyle.swift
//  Fehu
//
//  Created by Wolf McNally on 12/11/20.
//

import SwiftUI

struct FieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(Color(UIColor.quaternaryLabel))
            .cornerRadius(10)
    }
}

extension View {
    func fieldStyle() -> some View {
        modifier(FieldStyle())
    }
}

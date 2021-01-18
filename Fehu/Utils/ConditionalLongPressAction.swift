//
//  ConditionalLongPressAction.swift
//  Fehu
//
//  Created by Wolf McNally on 1/18/21.
//

import SwiftUI

struct ConditionalLongPressAction: ViewModifier {
    let actionEnabled: Bool
    let action: () -> Void
    
    func body(content: Content) -> some View {
        if actionEnabled {
            return content
                .onLongPressGesture(perform: action)
                .eraseToAnyView()
        } else {
            return content
                .eraseToAnyView()
        }
    }
}

extension View {
    func conditionalLongPressAction(actionEnabled: Bool, action: @escaping () -> Void) -> some View {
        modifier(ConditionalLongPressAction(actionEnabled: actionEnabled, action: action))
    }
}

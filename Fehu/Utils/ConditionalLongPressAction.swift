//
//  ConditionalLongPressAction.swift
//  Fehu
//
//  Created by Wolf McNally on 1/18/21.
//

import SwiftUI

struct LongPressAction: ViewModifier {
    let action: () -> Void
    @State var isPressing: Bool = false
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture(pressing: { isPressing in
                withAnimation(.easeOut(duration: isPressing ? 0.3 : 0.1)) {
                    self.isPressing = isPressing
                }
            }, perform: action)
            .scaleEffect(isPressing ? 1.1 : 1.0)
    }
}

extension View {
    func longPressAction(action: @escaping () -> Void) -> some View {
        modifier(LongPressAction(action: action))
    }
}

struct ConditionalLongPressAction: ViewModifier {
    let actionEnabled: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        if actionEnabled {
            return content
                .longPressAction(action: action)
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

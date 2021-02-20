//
//  TouchEventModifier.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

struct TouchEventModifier: ViewModifier {
    let didChangedPressed: (Bool) -> Void

    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        let drag = DragGesture(minimumDistance: 0)
            .updating($isPressed) { (value, gestureState, transaction) in
                gestureState = true
            }

        return content
            .gesture(drag)
            .onChange(of: isPressed, perform: { isPressed in
                self.didChangedPressed(isPressed)
            })
    }
}

extension View {
    func onTouchEvent(didChangedPressed: @escaping (Bool) -> Void) -> some View {
        modifier(TouchEventModifier(didChangedPressed: didChangedPressed))
    }
}

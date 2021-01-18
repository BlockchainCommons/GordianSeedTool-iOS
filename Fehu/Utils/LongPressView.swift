//
//  LongPressView.swift
//  Fehu
//
//  Created by Wolf McNally on 1/16/21.
//

import SwiftUI

//struct LongPressView<Content>: View where Content: View {
//    let content: () -> Content
//    let completion: () -> Void
//    @GestureState var isDetectingLongPress = false
//    
//    init(@ViewBuilder content: @escaping () -> Content, completion: @escaping () -> Void) {
//        self.content = content
//        self.completion = completion
//    }
//    
//    var longPress: some Gesture {
//        LongPressGesture(minimumDuration: 1)
//            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
//                gestureState = currentState
//                print(gestureState)
//                if currentState {
//                    transaction.animation = Animation.easeOut(duration: 0.4)
//                } else {
//                    transaction.animation = Animation.easeOut(duration: 0.1)
//                }
//            }
//            .onEnded { finished in
//                self.completion()
//            }
//    }
//    
//    var body: some View {
//        content()
//            .gesture(longPress)
//            .scaleEffect(isDetectingLongPress ? 0.5 : 1.0)
//    }
//}
//
//struct LongPressViewModifier: ViewModifier {
//    let completion: () -> Void
//    func body(content: Content) -> some View {
//        LongPressView(content: { content }, completion: completion)
//    }
//}
//
//extension View {
//    
//}
//
//struct LongPressView_Previews: PreviewProvider {
//    final class TestState: ObservableObject {
//        @Published var isCircle: Bool = true
//    }
//    
//    static var state = TestState()
//    
//    static var previews: some View {
//        ZStack {
//            Rectangle()
//                .fill(Color.green)
//                .frame(width: 100, height: 100)
//            LongPressView {
//                myView
//                    .frame(width: 100, height: 100)
//            } completion: {
//                state.isCircle.toggle()
//            }
//        }
//    }
//    
//    static var myView: some View {
//        if state.isCircle {
//            return Circle()
//                .fill(Color.red)
//                .eraseToAnyView()
//        } else {
//            return Rectangle()
//                .fill(Color.blue)
//                .eraseToAnyView()
//        }
//    }
//}

//
//  TapToDismiss.swift
//  Fehu
//
//  Created by Wolf McNally on 12/20/20.
//

import UIKit
import SwiftUI

// https://medium.com/swlh/dismissing-the-keyboard-in-swiftui-2-0-591025493375

extension UIApplication {
    func addTapToDismissGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // set to `false` if you don't want to detect tap during other gestures
    }
}

struct TapToDismiss: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear(perform: UIApplication.shared.addTapToDismissGestureRecognizer)
    }
}

extension View {
    func tapToDismiss() -> some View {
        modifier(TapToDismiss())
    }
}

// USE:
//
//    @main
//    struct TestApp: App {
//        var body: some Scene {
//            WindowGroup {
//                ContentView()
//                    .tapToDismiss()
//            }
//        }
//    }
//

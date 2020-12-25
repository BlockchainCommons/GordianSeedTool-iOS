//
//  CopyConfirmation.swift
//  Fehu
//
//  Created by Wolf McNally on 12/16/20.
//

import SwiftUI
import WolfSwiftUI
import MobileCoreServices

func copyToPasteboard(_ string: String, expiry: TimeInterval? = nil) {
    UIPasteboard.general.string = string
    let key = kUTTypeUTF8PlainText as String
    let value = string.data(using: .utf8)!
    let items = [[key: value]]

    let options: [UIPasteboard.OptionsKey : Any]
    if let expiry = expiry {
        let expiryDate = Date().addingTimeInterval(expiry)
        options = [.expirationDate : expiryDate]
    } else {
        options = [:]
    }
    UIPasteboard.general.setItems(items, options: options)
}

func copyToPasteboard(_ string: String, expiry: TimeInterval? = 60, isConfirmationPresented: Binding<Bool>) {
    copyToPasteboard(string, expiry: expiry)
    withAnimation(.easeOut(duration: 0.2)) {
        isConfirmationPresented.wrappedValue = true
    }
    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        withAnimation(.easeIn(duration: 0.2)) {
            isConfirmationPresented.wrappedValue = false
        }
    }
}

struct CopyConfirmation: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            ConfirmationOverlay(imageName: "doc.on.doc.fill", title: "Copied!", message: "The clipboard will be erased in 1 minute.")
                .opacity(isPresented ? 1 : 0)
        }
        .onChange(of: isPresented) { _ in

        }
    }
}

extension View {
    func copyConfirmation(isPresented: Binding<Bool>) -> some View {
        modifier(CopyConfirmation(isPresented: isPresented))
    }
}

#if DEBUG

struct CopyConfirmation_Previews: PreviewProvider {
    static let model: Model = Model()

    class Model: ObservableObject {
        @Published var isConfirmationPresented: Bool = false
    }

    struct PreviewView: View {
        @ObservedObject var model: Model

        var body: some View {
            VStack {
                Button() {
                    copyToPasteboard("Hello", isConfirmationPresented: $model.isConfirmationPresented)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .copyConfirmation(isPresented: $model.isConfirmationPresented)
        }
    }

    static var previews: some View {
        PreviewView(model: model)
    }

}

#endif

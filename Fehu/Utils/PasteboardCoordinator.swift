//
//  CopyConfirmation.swift
//  Fehu
//
//  Created by Wolf McNally on 12/16/20.
//

import SwiftUI
import WolfSwiftUI
import MobileCoreServices
import URKit

final class PasteboardCoordinator: ObservableObject {
    @Published var isConfirmationPresented: Bool = false

    func copyToPasteboard(_ string: String) {
        copyToPasteboard(value: string.data(using: .utf8)!, type: kUTTypeUTF8PlainText)
    }
    
    func copyToPasteboard(_ image: UIImage) {
        copyToPasteboard(value: image.pngData()!, type: kUTTypePNG)
    }
    
    func copyToPasteboard(_ ur: UR) {
        copyToPasteboard(UREncoder.encode(ur))
    }
    
    private func copyToPasteboard(value: Any, type: CFString, expiry: TimeInterval? = 60) {
        let items: [[String: Any]] = [[(type as String): value]]

        let options: [UIPasteboard.OptionsKey : Any]
        if let expiry = expiry {
            let expiryDate = Date().addingTimeInterval(expiry)
            options = [.expirationDate : expiryDate]
        } else {
            options = [:]
        }
        UIPasteboard.general.setItems(items, options: options)
        Feedback.copy.play()

        withAnimation(.easeOut(duration: 0.2)) {
            self.isConfirmationPresented = true
        }
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            withAnimation(.easeIn(duration: 0.2)) {
                self.isConfirmationPresented = false
            }
        }
    }
}

struct CopyConfirmation: ViewModifier {
    @EnvironmentObject var pasteboardCoordinator: PasteboardCoordinator

    func body(content: Content) -> some View {
        ZStack {
            content
            ConfirmationOverlay(imageName: "doc.on.doc.fill", title: "Copied!", message: "The clipboard will be erased in 1 minute.")
                .opacity(pasteboardCoordinator.isConfirmationPresented ? 1 : 0)
        }
        .onChange(of: pasteboardCoordinator.isConfirmationPresented) { _ in

        }
    }
}

extension View {
    func copyConfirmation() -> some View {
        modifier(CopyConfirmation())
    }
}

#if DEBUG

struct CopyConfirmation_Previews: PreviewProvider {

    struct PreviewView: View {
        @StateObject var pasteboardCoordinator = PasteboardCoordinator()

        var body: some View {
            VStack {
                Button() {
                    pasteboardCoordinator.copyToPasteboard("Hello")
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .copyConfirmation()
            .environmentObject(pasteboardCoordinator)
        }
    }

    static var previews: some View {
        PreviewView()
    }

}

#endif

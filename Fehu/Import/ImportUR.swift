//
//  ImportUR.swift
//  Fehu
//
//  Created by Wolf McNally on 12/19/20.
//

import SwiftUI
import WolfSwiftUI

struct ImportUR: View {
    @Binding var isPresented: Bool
    let addSeed: (Seed) -> Void
    @State private var text: String = ""
    @State var seed: Seed!
    @State var isValid: Bool = false

    var body: some View {
        VStack {
            inputArea
            outputArea
        }
        .padding()
        .navigationTitle("Import ur:crypto-seed")
        .navigationBarItems(leading: cancelButton, trailing: saveButton)
    }

    var cancelButton: some View {
        CancelButton {
            isPresented = false
        }
    }

    var saveButton: some View {
        SaveButton {
            addSeed(seed)
            isPresented = false
        }
        .disabled(!isValid)
    }

    var inputArea: some View {
        VStack {
            Text("Paste your ur:crypto-seed below.")
            TextEditor(text: $text)
                .fieldStyle()
        }
    }

    var outputArea: some View {
        Rectangle().fill(Color.red)
    }
}

struct ImportUR_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImportUR(isPresented: .constant(true), addSeed: { _ in })
        }
            .preferredColorScheme(.dark)
    }
}


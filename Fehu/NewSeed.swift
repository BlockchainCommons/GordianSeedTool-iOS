//
//  NewSeed.swift
//  Fehu
//
//  Created by Wolf McNally on 12/9/20.
//

import SwiftUI

struct NewSeedItem<KeypadType>: View where KeypadType: View & Keypad {
    @State var isPresented: Bool = false
    let imageName: String

    init(_ KeypadType: KeypadType.Type, imageName: String) {
        self.imageName = imageName
    }

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label(KeypadType.name, systemImage: imageName)
        }.sheet(isPresented: $isPresented, onDismiss: { }) {
            EntryView(keypadType: KeypadType.self, isDisplayed: $isPresented)
        }
    }
}

struct NewSeed: View {
    var body: some View {
        NavigationView {
            List {
                Text("Generate a new seed from entropy.")
                    .font(.footnote)
                    .padding()
                NewSeedItem(BitKeypad.self, imageName: "bitcoinsign.circle")
                NewSeedItem(DieKeypad.self, imageName: "die.face.3")
                NewSeedItem(ByteKeypad.self, imageName: "number")
                NewSeedItem(CardKeypad.self, imageName: "suit.heart")
                Text("Import an existing seed.")
                    .font(.footnote)
                    .padding()
                Label("QR Code (crypto-seed)", systemImage: "bitcoinsign.circle")
                Label("BIP39 mnemonic", systemImage: "bitcoinsign.circle")
                Label("SSKR", systemImage: "bitcoinsign.circle")
            }
            .padding()
            .accentColor(.green)
            .navigationTitle("Add Seed")
        }
    }
}

struct NewSeed_Previews: PreviewProvider {
    static var previews: some View {
        NewSeed()
            .preferredColorScheme(.dark)
    }
}

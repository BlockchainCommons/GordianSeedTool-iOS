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
    @State private var isHexDisplayed = false
    @State private var isCardsDisplayed = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Choose the style of entropy to use.")
                    .font(.footnote)
                    .padding()
                List {
                    NewSeedItem(CoinKeypad.self, imageName: "bitcoinsign.circle")
                    NewSeedItem(DiceKeypad.self, imageName: "die.face.3")
                    NewSeedItem(HexKeypad.self, imageName: "number")
                    NewSeedItem(PlayingCardKeypad.self, imageName: "suit.heart")
                }
            }
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

//
//  ContentView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

struct ContentView: View {
    @State private var isCoinsDisplayed = false
    @State private var isDiceDisplayed = false
    @State private var isHexDisplayed = false
    @State private var isCardsDisplayed = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Choose the style of entropy to use.")
                    .font(.footnote)
                    .padding()
                List {
                    Button {
                        isCoinsDisplayed = true
                    } label: {
                        HStack() {
                            Image(systemName: "bitcoinsign.circle")
                                .foregroundColor(.green)
                            Text(CoinKeypad.name)
                        }
                    }.sheet(isPresented: $isCoinsDisplayed, onDismiss: { }) {
                        EntryView(keypadType: CoinKeypad.self, isDisplayed: $isCoinsDisplayed)
                    }

                    Button {
                        isDiceDisplayed = true
                    } label: {
                        HStack() {
                            Image(systemName: "die.face.3")
                                .foregroundColor(.green)
                            Text(DiceKeypad.name)
                        }
                    }.sheet(isPresented: $isDiceDisplayed, onDismiss: { }) {
                        EntryView(keypadType: DiceKeypad.self, isDisplayed: $isDiceDisplayed)
                    }

                    Button {
                        isHexDisplayed = true
                    } label: {
                        HStack() {
                            Image(systemName: "number")
                                .foregroundColor(.green)
                            Text(HexKeypad.name)
                        }
                    }.sheet(isPresented: $isHexDisplayed, onDismiss: { }) {
                        EntryView(keypadType: HexKeypad.self, isDisplayed: $isHexDisplayed)
                    }

                    Button {
                        isCardsDisplayed = true
                    } label: {
                        HStack() {
                            Image(systemName: "suit.heart")
                                .foregroundColor(.green)
                            Text(PlayingCardKeypad.name)
                        }
                    }.sheet(isPresented: $isCardsDisplayed, onDismiss: { }) {
                        EntryView(keypadType: PlayingCardKeypad.self, isDisplayed: $isCardsDisplayed)
                    }
                }
            }
            .accentColor(.green)
            .navigationTitle("Generate a Seed")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

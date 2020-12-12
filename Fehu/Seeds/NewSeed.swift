//
//  NewSeed.swift
//  Fehu
//
//  Created by Wolf McNally on 12/9/20.
//

import SwiftUI

struct NewSeed: View {
    @Binding var isPresented: Bool
    let addSeed: (Seed) -> Void
    @State var newSeed: Seed?

    var body: some View {
        NavigationView {
            Form {
                Section {
                    sectionHeader("Generate a new seed with cryptographic strength.")
                    Button {
                        newSeed = Seed()
                        isPresented = false
                    } label: {
                        Label("Quick Create", systemImage: "hare")
                    }
                }

                Section {
                    sectionHeader("Generate a new seed from entropy you provide.")
                    KeypadItem(BitKeypad.self, imageName: "centsign.circle") { seed in
                        newSeed = seed
                        isPresented = false
                    }
                    KeypadItem(DieKeypad.self, imageName: "die.face.3") { seed in
                        newSeed = seed
                        isPresented = false
                    }
                    KeypadItem(CardKeypad.self, imageName: "suit.heart") { seed in
                        newSeed = seed
                        isPresented = false
                    }
                }

                Section {
                    sectionHeader("Import an existing seed.")
                    KeypadItem(ByteKeypad.self, imageName: "number") { seed in
                        newSeed = seed
                        isPresented = false
                    }
                    Item(title: "ur:crypto-seed", imageName: "u.circle")
                    Item(title: "Scan ur:crypto-seed QR Code", imageName: "qrcode.viewfinder")
                    Item(title: "BIP39 mnemonic", imageName: "b.circle")
                    Item(title: "SSKR", imageName: "s.circle")
                }
            }
            .padding()
            .accentColor(.green)
            .navigationTitle("Add Seed")
            .navigationBarItems(leading: cancelButton)
        }
        .onDisappear {
            if let newSeed = newSeed {
                addSeed(newSeed)
            }
        }
    }

    var cancelButton: some View {
        Button {
            isPresented = false
        } label: {
            Text("Cancel")
        }
    }

    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding()
    }

    struct Item: View {
        let title: String
        let imageName: String

        var body: some View {
            Button {

            } label: {
                Label(title, systemImage: imageName)
            }
        }
    }

    struct KeypadItem<KeypadType>: View where KeypadType: View & Keypad {
        @State var isPresented: Bool = false
        let imageName: String
        let addSeed: (Seed) -> Void

        init(_ KeypadType: KeypadType.Type, imageName: String, addSeed: @escaping (Seed) -> Void) {
            self.imageName = imageName
            self.addSeed = addSeed
        }

        var body: some View {
            Button {
                isPresented = true
            } label: {
                Label(KeypadType.name, systemImage: imageName)
            }.sheet(isPresented: $isPresented) {
                EntryView(keypadType: KeypadType.self, isPresented: $isPresented) { seed in
                    addSeed(seed)
                }
            }
        }
    }
}

struct NewSeed_Previews: PreviewProvider {
    static var previews: some View {
        NewSeed(isPresented: .constant(true), addSeed: { _ in })
            .preferredColorScheme(.dark)
    }
}

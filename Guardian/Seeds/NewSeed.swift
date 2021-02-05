//
//  NewSeed.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/9/20.
//

import SwiftUI
import WolfSwiftUI

struct NewSeed: View {
    @Binding var isPresented: Bool
    let addSeed: (Seed) -> Void
    @State var newSeed: Seed?

    func setNewSeed(newSeed: Seed) {
        self.newSeed = newSeed
        isPresented = false
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                RevealButton {
                    Text("Seeds are stored encrypted in the system keychain using your device passcode. When your device is locked no one can access them without the passcode.")
                } hidden: {
                    Text("Seeds are stored encrypted.")
                }
                Form {
                    Section {
                        sectionHeader("Generate a new seed with cryptographic strength.")
                        Button {
                            newSeed = Seed()
                            isPresented = false
                        } label: {
                            Label(
                                title: { Text("Quick Create") },
                                icon: { Image(systemName: "hare").resizable().aspectRatio(contentMode: .fit)})
                        }
                    }
                    
                    Section {
                        sectionHeader("Generate a new seed from entropy you provide.")
                        KeypadItem(BitKeypad.self, image: Image(systemName: "centsign.circle")) { seed in
                            newSeed = seed
                            isPresented = false
                        }
                        KeypadItem(DieKeypad.self, image: Image(systemName: "die.face.3")) { seed in
                            newSeed = seed
                            isPresented = false
                        }
                        KeypadItem(CardKeypad.self, image: Image(systemName: "suit.heart")) { seed in
                            newSeed = seed
                            isPresented = false
                        }
                    }
                    
                    Section {
                        sectionHeader("Import an existing seed.")
                        
                        KeypadItem(
                            ByteKeypad.self,
                            image: Image("hex.bar"),
                            addSeed: setNewSeed
                        )
                        
                        ImportItem(
                            ImportChildView<ImportURModel>.self,
                            title: "Scan ur:crypto-seed QR Code",
                            image: Image(systemName: "qrcode.viewfinder"),
                            shouldScan: true,
                            addSeed: setNewSeed
                        )
                        
                        ImportItem(
                            ImportChildView<ImportURModel>.self,
                            title: "ur:crypto-seed",
                            image: Image("ur.bar"),
                            shouldScan: false,
                            addSeed: setNewSeed
                        )
                        
                        ImportItem(
                            ImportChildView<ImportByteWordsModel>.self,
                            title: "ByteWords",
                            image: Image("bytewords.bar"),
                            shouldScan: false,
                            addSeed: setNewSeed
                        )
                        
                        ImportItem(
                            ImportChildView<ImportBIP39Model>.self,
                            title: "BIP39 mnemonic",
                            image: Image("39.bar"),
                            shouldScan: false,
                            addSeed: setNewSeed
                        )
                        
                        ImportItem(
                            ImportChildView<ImportSSKRModel>.self,
                            title: "SSKR",
                            image: Image("sskr.bar"),
                            shouldScan: false,
                            addSeed: setNewSeed
                        )
                    }
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
        CancelButton {
            isPresented = false
        }
    }

    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding()
    }

    struct ImportItem<ImportChildViewType>: View where ImportChildViewType: Importer {
        @State var isPresented: Bool = false
        let title: String
        let image: Image
        let shouldScan: Bool
        let addSeed: (Seed) -> Void
        
        init(_ importChildViewType: ImportChildViewType.Type, title: String, image: Image, shouldScan: Bool, addSeed: @escaping (Seed) -> Void) {
            self.title = title
            self.image = image
            self.shouldScan = shouldScan
            self.addSeed = addSeed
        }

        var body: some View {
            Button {
                isPresented = true
            } label: {
                MenuLabel(title, icon: image)
            }
            .sheet(isPresented: $isPresented) {
                ImportParentView(importChildViewType: ImportChildViewType.self, isPresented: $isPresented, shouldScan: shouldScan) { seed in
                    addSeed(seed)
                }
            }
        }
    }

    struct KeypadItem<KeypadType>: View where KeypadType: View & Keypad {
        @State var isPresented: Bool = false
        let image: Image
        let addSeed: (Seed) -> Void

        init(_ KeypadType: KeypadType.Type, image: Image, addSeed: @escaping (Seed) -> Void) {
            self.image = image
            self.addSeed = addSeed
        }

        var body: some View {
            Button {
                isPresented = true
            } label: {
                MenuLabel(KeypadType.name, icon: image)
            }.sheet(isPresented: $isPresented) {
                EntropyView(keypadType: KeypadType.self, isPresented: $isPresented) { seed in
                    addSeed(seed)
                }
            }
        }
    }
}

#if DEBUG

struct NewSeed_Previews: PreviewProvider {
    static var previews: some View {
        NewSeed(isPresented: .constant(true), addSeed: { _ in })
            .darkMode()
    }
}

#endif

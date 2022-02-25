//
//  NewSeed.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import SwiftUI
import WolfSwiftUI

struct AddSeedButton: View {
    @State private var isPresented = false
    let addSeed: (ModelSeed) -> Void
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $isPresented) {
            NewSeed(isPresented: $isPresented, addSeed: addSeed)
        }
    }
}

struct NewSeed: View {
    @Binding var isPresented: Bool
    let addSeed: (ModelSeed) -> Void
    @State var newSeed: ModelSeed?

    func setNewSeed(newSeed: ModelSeed) {
        self.newSeed = newSeed
        isPresented = false
    }
    
    func section<Content>(title: Text, chapter: Chapter? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                sectionHeader(title)
                Spacer()
                if let chapter = chapter {
                    UserGuideButton(openToChapter: chapter)
                        .padding([.trailing], 5)
                }
            }
            content()
        }
        .formSectionStyle()
    }
    
    func sectionItem<Content>(chapter: Chapter? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        HStack(alignment: .firstTextBaseline) {
            content()
            Spacer()
            if let chapter = chapter {
                UserGuideButton(openToChapter: chapter)
            }
        }
        .padding(5)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    section(title: Text("Generate a new seed with cryptographic strength."), chapter: .whatIsASeed) {
                        sectionItem {
                            Button {
                                newSeed = ModelSeed()
                                isPresented = false
                            } label: {
                                MenuLabel(Text("Quick Create"), icon: Image(systemName: "hare"))
                            }
                        }
                    }

                    section(title: Text("Generate a new seed from entropy you provide."), chapter: .whatIsASeed) {
                        sectionItem {
                            KeypadItem(BitKeypad.self, image: Image(systemName: "centsign.circle")) { seed in
                                newSeed = seed
                                isPresented = false
                            }
                        }

                        sectionItem {
                            KeypadItem(DieKeypad.self, image: Image(systemName: "die.face.3")) { seed in
                                newSeed = seed
                                isPresented = false
                            }
                        }

                        sectionItem {
                            KeypadItem(CardKeypad.self, image: Image(systemName: "suit.heart")) { seed in
                                newSeed = seed
                                isPresented = false
                            }
                        }
                    }

                    section(title: Text("Import an existing seed from text. You can also use the ") +
                                Text(Image(systemName: "qrcode.viewfinder")) +
                                Text(" button on the previous screen to import a ur:crypto-seed QR code.")) {
                        
                        sectionItem(chapter: .whatIsAUR) {
                            ImportItem(
                                ImportChildView<ImportSeedModel>.self,
                                title: "ur:crypto-seed",
                                image: Image("ur.bar"),
                                addSeed: setNewSeed
                            )
                        }

                        sectionItem(chapter: .whatAreBytewords) {
                            ImportItem(
                                ImportChildView<ImportByteWordsModel>.self,
                                title: "ByteWords",
                                image: Image("bytewords.bar"),
                                addSeed: setNewSeed
                            )
                        }

                        sectionItem(chapter: .whatIsSSKR) {
                            ImportItem(
                                ImportChildView<ImportSSKRModel>.self,
                                title: "SSKR",
                                image: Image("sskr.bar"),
                                addSeed: setNewSeed
                            )
                        }

                        sectionItem {
                            ImportItem(
                                ImportChildView<ImportBIP39Model>.self,
                                title: "BIP39 mnemonic",
                                image: Image("39.bar"),
                                addSeed: setNewSeed
                            )
                        }

                        sectionItem {
                            KeypadItem(
                                ByteKeypad.self,
                                image: Image("hex.bar"),
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
        }
        .dismissOnNavigationEvent(isPresented: $isPresented)
        .onDisappear {
            if let newSeed = newSeed {
                addSeed(newSeed)
            }
        }
        .font(.body)
    }
    
    var cancelButton: some View {
        CancelButton($isPresented)
            .accessibility(label: Text("Cancel Add Seed"))
            .keyboardShortcut(.cancelAction)
    }

    func sectionHeader(_ text: Text) -> some View {
        VStack(alignment: .leading) {
            text
                .font(.caption)
                .fixedVertical()
                .padding(10)
            Divider()
        }
    }

    struct ImportItem<ImportChildViewType>: View where ImportChildViewType: Importer {
        @State var isPresented: Bool = false
        let title: String
        let image: Image
        let addSeed: (ModelSeed) -> Void
        
        init(_ importChildViewType: ImportChildViewType.Type, title: String, image: Image, addSeed: @escaping (ModelSeed) -> Void) {
            self.title = title
            self.image = image
            self.addSeed = addSeed
        }

        var body: some View {
            HStack {
                Button {
                    isPresented = true
                } label: {
                    HStack {
                        MenuLabel(title, icon: image)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $isPresented) {
                ImportParentView(importChildViewType: ImportChildViewType.self, isPresented: $isPresented) { seed in
                    addSeed(seed)
                }
            }
        }
    }

    struct KeypadItem<KeypadType>: View where KeypadType: View & Keypad {
        @State var isPresented: Bool = false
        let image: Image
        let addSeed: (ModelSeed) -> Void

        init(_ KeypadType: KeypadType.Type, image: Image, addSeed: @escaping (ModelSeed) -> Void) {
            self.image = image
            self.addSeed = addSeed
        }

        var body: some View {
            Button {
                isPresented = true
            } label: {
                HStack {
                    MenuLabel(KeypadType.name, icon: image)
                    Spacer()
                }
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

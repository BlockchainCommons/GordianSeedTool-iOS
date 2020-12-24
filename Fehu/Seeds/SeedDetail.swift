//
//  SeedDetail.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

struct SeedDetail: View {
    @ObservedObject var seed: Seed
    @Binding var isValid: Bool
    let saveWhenChanged: Bool
    let provideSuggestedName: Bool
    @State private var isEditingNameField: Bool = false
    @State private var isCopyConfirmationDisplayed: Bool = false
    @State private var presentedSheet: Sheet? = nil

    init(seed: Seed, saveWhenChanged: Bool, provideSuggestedName: Bool = false, isValid: Binding<Bool>) {
        self.seed = seed
        self.saveWhenChanged = saveWhenChanged
        self.provideSuggestedName = provideSuggestedName
        _isValid = isValid
    }

    enum Sheet: Int, Identifiable {
        case ur
        case sskr

        var id: Int { rawValue }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                identity
                details
                data
                name
                notes
            }
            .padding()
        }
        .onReceive(seed.needsSavePublisher) { _ in
            if saveWhenChanged {
                seed.save()
            }
        }
        .onReceive(seed.isValidPublisher) {
            isValid = $0
        }
        .navigationBarBackButtonHidden(!isValid)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: shareMenu)
        .copyConfirmation(isPresented: $isCopyConfirmationDisplayed)
        .sheet(item: $presentedSheet) { item -> AnyView in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .ur:
                return URView(subject: seed, isPresented: isSheetPresented).eraseToAnyView()
            case .sskr:
                return SSKRSetup(seed: seed, isPresented: isSheetPresented).eraseToAnyView()
            }
        }
        .frame(maxWidth: 600)
    }

    var identity: some View {
        ModelObjectIdentity(id: seed.id, fingerprint: seed.fingerprint, type: .seed, name: $seed.name, provideSuggestedName: provideSuggestedName)
            .frame(height: 128)
    }

    var details: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Size: ").bold() + Text("\(seedBits) bits")
                Text("Strength: ").bold() + Text("\(entropyStrength.description)")
                    .foregroundColor(entropyStrengthColor)
            }
            Spacer()
        }
    }

    var data: some View {
        HStack {
            VStack(alignment: .leading) {
                Label("Data", systemImage: "shield.lefthalf.fill")
                RevealButton {
                    Text(seed.data.hex)
                        .font(.system(.body, design: .monospaced))
                } hidden: {
                    Text("Hidden")
                        .foregroundColor(.secondary)
                }
                .fieldStyle()
            }
            Spacer()
        }
    }

    var name: some View {
        VStack(alignment: .leading) {
            Label("Name", systemImage: "quote.bubble")

            HStack {
                TextField("Name", text: $seed.name) { isEditing in
                    withAnimation {
                        isEditingNameField = isEditing
                    }
                }
                if isEditingNameField {
                    FieldClearButton(text: $seed.name)
                    FieldRandomTitleButton(seed: seed, text: $seed.name)
                }
            }
            .validation(seed.nameValidator)
            .fieldStyle()
            .font(.title)
        }
    }

    var notes: some View {
        VStack(alignment: .leading) {
            Label("Notes", systemImage: "note.text")

            TextEditor(text: $seed.note)
                .frame(minHeight: 300)
                .fixedVertical()
                .fieldStyle()
        }
    }

    var shareMenu: some View {
        Menu {
            ContextMenuItem(title: "Copy as Hex", imageName: "number") {
                copyToPasteboard(seed.hex, isConfirmationPresented: $isCopyConfirmationDisplayed)
            }
            ContextMenuItem(title: "Copy as ur:crypto-seed", imageName: "u.circle") {
                copyToPasteboard(seed.urString, isConfirmationPresented: $isCopyConfirmationDisplayed)
            }
            ContextMenuItem(title: "Copy as BIP39 words", imageName: "39.circle") {
                copyToPasteboard(seed.bip39, isConfirmationPresented: $isCopyConfirmationDisplayed)
            }
            ContextMenuItem(title: "Copy as SSKR words", imageName: "s.circle") {
                copyToPasteboard(seed.sskr, isConfirmationPresented: $isCopyConfirmationDisplayed)
            }
            ContextMenuItem(title: "Display ur:crypto-seed QR Code…", imageName: "qrcode") {
                presentedSheet = .ur
            }
            ContextMenuItem(title: "Export as SSKR multi-share…", imageName: "s.circle") {
                presentedSheet = .sskr
            }
        } label: {
            Image(systemName: "square.and.arrow.up.on.square")
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .disabled(!isValid)
    }

    var seedBytes: Int {
        seed.data.count
    }

    var seedBits: Int {
        seedBytes * 8
    }

    var entropyStrength: EntropyStrength {
        EntropyStrength.categorize(Double(seedBits))
    }

    var entropyStrengthColor: Color {
        entropyStrength.color
    }
}

#if DEBUG

import WolfLorem

struct SeedDetail_Previews: PreviewProvider {
    static let seed = Lorem.seed()

    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    static var previews: some View {
        NavigationView {
            SeedDetail(seed: seed, saveWhenChanged: true, isValid: .constant(true))
        }
        .preferredColorScheme(.dark)
    }
}

#endif

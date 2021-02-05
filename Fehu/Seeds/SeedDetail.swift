//
//  SeedDetail.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI
import Combine

struct TestnetWarning: View {
    let network: Network
    
    var body: some View {
        switch network {
        case .mainnet:
            return EmptyView().eraseToAnyView()
        case .testnet:
            return Image("network.test").eraseToAnyView()
        }
    }
}

struct SeedDetail: View {
    @ObservedObject var seed: Seed
    @Binding var isValid: Bool
    let saveWhenChanged: Bool
    let provideSuggestedName: Bool
    @State private var isEditingNameField: Bool = false
    @State private var presentedSheet: Sheet? = nil
    @EnvironmentObject private var settings: Settings
    
    private var seedCreationDate: Binding<Date> {
        Binding<Date>(get: {
            return seed.creationDate ?? Date()
        }, set: {
            seed.creationDate = $0
        })
    }

    init(seed: Seed, saveWhenChanged: Bool, provideSuggestedName: Bool = false, isValid: Binding<Bool>) {
        self.seed = seed
        self.saveWhenChanged = saveWhenChanged
        self.provideSuggestedName = provideSuggestedName
        _isValid = isValid
    }

    enum Sheet: Int, Identifiable {
        case seedUR
        case gordianPublicKeyUR
        case sskr
        case key
        case print

        var id: Int { rawValue }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                identity
                details
                publicKey
                data
                name
                creationDate
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
        .sheet(item: $presentedSheet) { item -> AnyView in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .seedUR:
                return URView(subject: seed, isPresented: isSheetPresented)
                    .eraseToAnyView()
            case .gordianPublicKeyUR:
                return URView(subject: KeyExportModel.deriveGordianPublicKey(seed: seed, network: settings.defaultNetwork), isPresented: isSheetPresented)
                    .eraseToAnyView()
            case .sskr:
                return SSKRSetup(seed: seed, isPresented: isSheetPresented)
                    .eraseToAnyView()
            case .key:
                return KeyExport(seed: seed, isPresented: isSheetPresented)
                    .eraseToAnyView()
            case .print:
                return SeedPrintSetup(seed: seed, isPresented: isSheetPresented)
                    .eraseToAnyView()
            }
        }
        .frame(maxWidth: 600)
    }

    var identity: some View {
        ModelObjectIdentity(model: .constant(seed), provideSuggestedName: provideSuggestedName)
            .frame(height: 128)
    }

    var details: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Size: ").bold() + Text("\(seedBits) bits")
                Text("Strength: ").bold() + Text("\(entropyStrength.description)")
                    .foregroundColor(entropyStrengthColor)
//                Text("Creation Date: ").bold() + Text("unknown").foregroundColor(.secondary)
            }
            Spacer()
        }
    }
    
    static var dataLabel: some View {
        Label(
            title: { Text("Data").bold() },
            icon: { Image(systemName: "shield.lefthalf.fill") }
        )
    }

    var data: some View {
        HStack {
            VStack(alignment: .leading) {
                Self.dataLabel
                LockRevealButton {
                    HStack(alignment: .top) {
                        Text(seed.data.hex)
                            .monospaced()
                            .longPressAction {
                                PasteboardCoordinator.shared.copyToPasteboard(seed.data.hex)
                            }
                        shareMenu
                    }
                } hidden: {
                    Text("Encrypted")
                        .foregroundColor(.secondary)
                }
                .formSectionStyle()
            }
            Spacer()
        }
    }
    
    var publicKey: some View {
        HStack {
            TestnetWarning(network: settings.defaultNetwork)
            ExportSafeDataButton("Gordian Public Key", icon: Image("bc-logo")) {
                presentedSheet = .gordianPublicKeyUR
            }
            Spacer()
        }
    }
    
    static var creationDateLabel: some View {
        Label(
            title: { Text("Creation Date").bold() },
            icon: { Image(systemName: "calendar") }
        )
    }
    
    var creationDate: some View {
        VStack(alignment: .leading) {
            Self.creationDateLabel
            HStack {
                if seed.creationDate != nil {
                    DatePicker(selection: seedCreationDate, displayedComponents: .date) {
                        Text("Creation Date")
                    }
                    .labelsHidden()
                    Spacer()
                    ClearButton {
                        seed.creationDate = nil
                    }
                    .font(.title3)
                } else {
                    Button {
                        seed.creationDate = Date()
                    } label: {
                        Text("unknown")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .formSectionStyle()
        }
    }
    
    static var nameLabel: some View {
        Label(
            title: { Text("Name").bold() },
            icon: { Image(systemName: "quote.bubble") }
        )
    }

    var name: some View {
        VStack(alignment: .leading) {
            Self.nameLabel

            HStack {
                TextField("Name", text: $seed.name) { isEditing in
                    withAnimation {
                        isEditingNameField = isEditing
                    }
                }
                if isEditingNameField {
                    HStack(spacing: 20) {
                        FieldRandomTitleButton(seed: seed, text: $seed.name)
                        FieldClearButton(text: $seed.name)
                    }
                    .font(.title3)
                }
            }
            .validation(seed.nameValidator)
            .formSectionStyle()
            .font(.body)
        }
    }
    
    static var notesLabel: some View {
        Label(
            title: { Text("Notes").bold() },
            icon: { Image(systemName: "note.text") }
        )
    }

    var notes: some View {
        VStack(alignment: .leading) {
            Self.notesLabel

            TextEditor(text: $seed.note)
                .id("notes")
                .frame(minHeight: 300)
                .fixedVertical()
                .formSectionStyle()
        }
    }

    var shareMenu: some View {
        Menu {
            ContextMenuItem(title: "Export as ur:crypto-seed…", image: Image("ur.bar")) {
                presentedSheet = .seedUR
            }
            ContextMenuItem(title: "Derive and Export Key…", image: Image("key.fill.circle")) {
                presentedSheet = .key
            }
            ContextMenuItem(title: "Export as SSKR Multi-Share…", image: Image("sskr.bar")) {
                presentedSheet = .sskr
            }
            ContextMenuItem(title: "Print Seed Backup…", image: Image(systemName: "printer")) {
                presentedSheet = .print
            }
            ContextMenuItem(title: "Copy as ByteWords", image: Image("bytewords.bar")) {
                PasteboardCoordinator.shared.copyToPasteboard(seed.byteWords)
            }
            ContextMenuItem(title: "Copy as BIP39 Words", image: Image("39.bar")) {
                PasteboardCoordinator.shared.copyToPasteboard(seed.bip39)
            }
            ContextMenuItem(title: "Copy as Hex", image: Image("hex.bar")) {
                PasteboardCoordinator.shared.copyToPasteboard(seed.hex)
            }
        } label: {
            Image(systemName: "square.and.arrow.up.on.square")
                .padding([.leading, .trailing, .bottom], 8)
                .accentColor(.yellowLightSafe)
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
        .darkMode()
    }
}

#endif

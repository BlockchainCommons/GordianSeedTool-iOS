//
//  SeedDetail.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI
import Combine

struct SeedDetail: View {
    @ObservedObject var seed: Seed
    @Binding var isValid: Bool
    @Binding var selectionID: UUID?
    let saveWhenChanged: Bool
    let provideSuggestedName: Bool
    @State private var isEditingNameField: Bool = false
    @State private var presentedSheet: Sheet? = nil
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var model: Model

    private var seedCreationDate: Binding<Date> {
        Binding<Date>(get: {
            return seed.creationDate ?? Date()
        }, set: {
            seed.creationDate = $0
        })
    }

    init(seed: Seed, saveWhenChanged: Bool, provideSuggestedName: Bool = false, isValid: Binding<Bool>, selectionID: Binding<UUID?>) {
        self.seed = seed
        self.saveWhenChanged = saveWhenChanged
        self.provideSuggestedName = provideSuggestedName
        _isValid = isValid
        _selectionID = selectionID
    }

    enum Sheet: Int, Identifiable {
        case seedUR
        case gordianPublicKeyUR
        case gordianPrivateKeyUR
        case sskr
        case key
        case debugRequest
        case debugResponse

        var id: Int { rawValue }
    }
    
    var body: some View {
        if selectionID == seed.id {
            main
        } else {
            EmptyView()
        }
    }
    
    var main: some View {
        ScrollView {
            VStack(spacing: 20) {
                identity
                details
                publicKey
                data
                name
                creationDate
                notes
                #if DEBUG
                debugRequestAndResponse
                #endif
            }
            .frame(maxWidth: 600)
            .padding()
        }
        .onReceive(seed.needsSavePublisher) { _ in
            if saveWhenChanged {
                seed.save(model: model, replicateToCloud: true)
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
                return ModelObjectExport(isPresented: isSheetPresented, isSensitive: true, subject: seed)
                    .eraseToAnyView()
            case .gordianPublicKeyUR:
                return ModelObjectExport(isPresented: isSheetPresented, isSensitive: false, subject: KeyExportModel.deriveGordianKey(seed: seed, network: settings.defaultNetwork, keyType: .public, isDerivable: true))
                    .eraseToAnyView()
            case .gordianPrivateKeyUR:
                return ModelObjectExport(isPresented: isSheetPresented, isSensitive: true, subject: KeyExportModel.deriveGordianKey(seed: seed, network: settings.defaultNetwork, keyType: .private, isDerivable: true))
                    .eraseToAnyView()
            case .sskr:
                return SSKRSetup(seed: seed, isPresented: isSheetPresented)
                    .eraseToAnyView()
            case .key:
                return KeyExport(seed: seed, isPresented: isSheetPresented, network: settings.defaultNetwork)
                    .eraseToAnyView()
            case .debugRequest:
                return URExport(
                    isPresented: isSheetPresented,
                    isSensitive: false,
                    ur: TransactionRequest(
                        body: .seed(SeedRequestBody(fingerprint: seed.fingerprint))
                    )
                    .ur
                )
                .eraseToAnyView()
            case .debugResponse:
                return URExport(
                    isPresented: isSheetPresented,
                    isSensitive: true,
                    ur: TransactionResponse(
                        id: UUID(),
                        body: .seed(seed)
                    )
                    .ur
                )
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
        VStack(alignment: .leading, spacing: 5) {
            Label(
                title: { Text("Encrypted Data").bold() },
                icon: { Image(systemName: "shield.lefthalf.fill") }
            )
            Text("Authenticate to export your seed, back it up, or use it to derive keys.")
                .font(.caption)
                .fixedVertical()
        }
    }

    var data: some View {
        HStack {
            VStack(alignment: .leading) {
                Self.dataLabel
                LockRevealButton {
                    HStack {
                        VStack(alignment: .leading) {
                            backupMenu
                            copyMenu
                            deriveKeyMenu
                        }
                        Spacer()
                    }
                } hidden: {
                    Text("Authenticate")
                        .foregroundColor(.yellowLightSafe)
                }
            }
            Spacer()
        }
    }
    
    var publicKey: some View {
        HStack {
            ExportDataButton(Text("Cosigner Public Key") + settings.defaultNetwork.textSuffix, icon: Image("bc-logo"), isSensitive: false) {
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
                    .accessibility(label: Text("Clear Date"))
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
                .accessibility(label: Text("Name Field"))
                if isEditingNameField {
                    HStack(spacing: 20) {
                        FieldRandomTitleButton(seed: seed, text: $seed.name)
                        FieldClearButton(text: $seed.name)
                            .accessibility(label: Text("Clear Name"))
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
                .accessibility(label: Text("Notes Field"))
        }
    }
    
    var debugRequestAndResponse: some View {
        Bug {
            VStack(alignment: .leading) {
                Button {
                    presentedSheet = .debugRequest
                } label: {
                    Text("Show Request for This Seed")
                        .bold()
                }

                Button {
                    presentedSheet = .debugResponse
                } label: {
                    Text("Show Response for This Seed")
                        .bold()
                }
            }
        }
    }
    
    var copyMenu: some View {
        Menu {
            ContextMenuItem(title: "Copy as ur:crypto-seed", image: Image("ur.bar")) {
                PasteboardCoordinator.shared.copyToPasteboard(seed.urString)
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
            ExportDataButton("Copy to Clipboard", icon: Image(systemName: "doc.on.doc"), isSensitive: true) {}
        }
    }
    
    var deriveKeyMenu: some View {
        Menu {
            ContextMenuItem(title: Text("Cosigner Private Key…"), image: Image("bc-logo")) {
                presentedSheet = .gordianPrivateKeyUR
            }
            ContextMenuItem(title: "Other Key Derivations…", image: Image("key.fill.circle")) {
                presentedSheet = .key
            }
        } label: {
            ExportDataButton("Derive Key", icon: Image("key.fill.circle"), isSensitive: true) {}
        }
    }

    var backupMenu: some View {
        Menu {
            ContextMenuItem(title: "Backup as ur:crypto-seed…", image: Image("ur.bar")) {
                presentedSheet = .seedUR
            }
            ContextMenuItem(title: "Backup as SSKR Multi-Share…", image: Image("sskr.bar")) {
                presentedSheet = .sskr
            }
        } label: {
            ExportDataButton("Backup", icon: Image(systemName: "archivebox"), isSensitive: true) {}
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .disabled(!isValid)
        .accessibility(label: Text("Share Seed Menu"))
        .accessibilityRemoveTraits(.isImage)
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
            SeedDetail(seed: seed, saveWhenChanged: true, isValid: .constant(true), selectionID: .constant(seed.id))
                .environmentObject(Settings(storage: MockSettingsStorage()))
        }
        .darkMode()
    }
}

#endif

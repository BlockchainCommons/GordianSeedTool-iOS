//
//  SeedDetail.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI
import BIP39

struct SeedDetail: View {
    @ObservedObject var seed: Seed
    @State private var isValid: Bool = true
    @State private var isEditingNameField: Bool = false
    @State private var isSeedVisible: Bool = false
    @State private var isCopyConfirmationDisplayed: Bool = false
    @State private var presentedSheet: Sheet? = nil

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
        .navigationBarBackButtonHidden(!isValid)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: shareMenu)
        .tapDismissesKeyboard()
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
                return Text("SSKR").eraseToAnyView()
            }
        }
    }

    var identity: some View {
        ModelObjectIdentity(fingerprint: seed.fingerprint, type: .seed, name: $seed.name)
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
                HStack {
                    Button {
                        withAnimation {
                            withAnimation {
                                isSeedVisible.toggle()
                            }
                        }
                    } label: {
                        Image(systemName: isSeedVisible ? "eye.slash" : "eye")
                    }
                    Text(
                        isSeedVisible ? seed.data.hex : "Hidden"
                    ).font(
                        .system(.body, design: isSeedVisible ? .monospaced : .default)
                    )
                    .bold()
                    .foregroundColor(isSeedVisible ? .primary : .secondary)
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
                    FieldRandomTitleButton(text: $seed.name)
                }
            }
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
    // praise patrol paddle catch wage resource there hurt problem act soccer spice
    var shareMenu: some View {
        Menu {
            ContextMenuItem(title: "Copy as Hex", imageName: "number") {
                copyToPasteboard(seed.hex, isConfirmationPresented: $isCopyConfirmationDisplayed)
            }
            ContextMenuItem(title: "Copy as ur:crypto-seed", imageName: "u.circle") {
                copyToPasteboard(seed.urString, isConfirmationPresented: $isCopyConfirmationDisplayed)
            }
            ContextMenuItem(title: "Copy as BIP39", imageName: "b.circle") {
                copyToPasteboard(try! BIP39.encode(seed.data), isConfirmationPresented: $isCopyConfirmationDisplayed)
            }
            ContextMenuItem(title: "Display ur:crypto-seed QR Code…", imageName: "qrcode") {
                presentedSheet = .ur
//                sheet = Text("UR").background(Color.red).eraseToAnyView()//URView(subject: seed, isPresented: $isSheetPresented).eraseToAnyView()
            }
            ContextMenuItem(title: "Export as SSKR…", imageName: "s.circle") {
                presentedSheet = .sskr
//                sheet = Text("SSKR").background(Color.blue).eraseToAnyView()
            }
        } label: {
            Image(systemName: "square.and.arrow.up.on.square")
        }
        .menuStyle(BorderlessButtonMenuStyle())
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
            SeedDetail(seed: seed)
        }
        .preferredColorScheme(.dark)
    }
}

#endif

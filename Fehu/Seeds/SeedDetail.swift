//
//  SeedDetail.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

struct SeedDetail: View {
    @ObservedObject var seed: Seed
    @State var isValid: Bool = true
    @State var isEditingNameField: Bool = false
    @State var isSeedVisible: Bool = false

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

    var shareMenu: some View {
        Menu {
            ContextMenuItem(title: "Copy as Hex", imageName: "number") {
            }
            ContextMenuItem(title: "Copy as ur:crypto-seed", imageName: "u.circle") {
            }
            ContextMenuItem(title: "Display ur:crypto-seed QR Code", imageName: "qrcode") {
            }
            ContextMenuItem(title: "Copy as BIP39", imageName: "b.circle") {
            }
            ContextMenuItem(title: "Export as SSKR", imageName: "s.circle") {
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

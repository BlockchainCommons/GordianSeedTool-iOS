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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                identity
                details
                form
            }
            .padding()
        }
        .navigationBarBackButtonHidden(!isValid)
        .navigationBarTitleDisplayMode(.inline)
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

    var form: some View {
        VStack(alignment: .leading) {
            Label("Name", systemImage: "quote.bubble")
                .padding(.top, 20)

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

            Label("Notes", systemImage: "note.text")
                .padding(.top, 20)

            TextEditor(text: $seed.note)
                .frame(minHeight: 300)
                .fixedVertical()
                .fieldStyle()
        }
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

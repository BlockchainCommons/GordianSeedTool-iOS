//
//  SeedBackupPage.swift
//  Guardian
//
//  Created by Wolf McNally on 2/3/21.
//

import SwiftUI
import URUI
import WolfSwiftUI
import SwiftUIPrint

struct SeedBackupPage: View {
    let seed: Seed
    @State private var lifeHashHeight: CGFloat = 0
    let margins: CGFloat = 72 * 0.5

    struct LifeHashHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0.25 * 72) {
                identity
                    .background(GeometryReader { p in
                        Color.clear
                            .preference(key: LifeHashHeightKey.self, value: p.size.height)
                    })
                qrCode
                    .frame(width: lifeHashHeight, height: lifeHashHeight)
            }
            data
            byteWords
            bip39
            if seed.creationDate != nil {
                creationDate
            }
            if !seed.note.isEmpty {
                note
            }
            Spacer()
        }
        .padding(margins)
        .environment(\.sizeCategory, .extraLarge)
        .onPreferenceChange(LifeHashHeightKey.self) {
            lifeHashHeight = $0
        }
    }
    
    var qrCode: some View {
        let message = seed.sizeLimitedURString.uppercased().data(using: .utf8)!
        let uiImage = makeQRCodeImage(message, correctionLevel: .low)
        let scaledImage = uiImage.scaled(by: 8)
        return Image(uiImage: scaledImage)
            .renderingMode(.template)
            .interpolation(.none)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    var identity: some View {
        ModelObjectIdentity(model: .constant(seed), allowLongPressCopy: false, generateLifeHashAsync: false, lifeHashWeight: 0.5)
    }
    
    var hexLabel: some View {
        Label(
            title: { Text("Hex").bold() },
            icon: { Image("hex.bar") }
        )
    }

    var data: some View {
        VStack(alignment: .leading) {
            hexLabel
            Text(seed.data.hex)
                .monospaced()
        }
    }
    
    var byteWordsLabel: some View {
        Label(
            title: { Text("ByteWords").bold() },
            icon: { Image("bytewords.bar") }
        )
    }

    var byteWords: some View {
        VStack(alignment: .leading) {
            byteWordsLabel
            Text(seed.byteWords)
                .monospaced()
        }
    }
    
    var bip39Label: some View {
        Label(
            title: { Text("BIP39 Words").bold() },
            icon: { Image("39.bar") }
        )
    }
    
    var bip39: some View {
        VStack(alignment: .leading) {
            bip39Label
            Text(seed.bip39)
                .monospaced()
        }
    }
    
    static var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    var creationDate: some View {
        VStack(alignment: .leading) {
            if let date = seed.creationDate {
                SeedDetail.creationDateLabel
                Text(Self.dateFormatter.string(from: date))
            }
        }
    }
    
    var note: some View {
        VStack(alignment: .leading) {
            if let note = seed.note {
                SeedDetail.notesLabel
                Text(note)
                    .minimumScaleFactor(0.5)
                    .frame(minHeight: 0, maxHeight: 1.5 * 72)
                    .fixedVertical()
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct SeedBackupPage_Previews: PreviewProvider {
    static let seed = Lorem.seed()

    static var previews: some View {
        SeedBackupPage(seed: seed)
            .previewLayout(.fixed(width: 8.5 * 72, height: 11 * 82))
    }
}

#endif

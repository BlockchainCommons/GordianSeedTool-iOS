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
    
    var body: some View {
        BackupPage(subject: seed, footer: footer)
    }
    
    var footer: some View {
        Group {
            data
            byteWords
            bip39
            if seed.creationDate != nil {
                creationDate
            }
            if !seed.note.isEmpty {
                note
            }
        }
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

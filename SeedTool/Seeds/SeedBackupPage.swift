//
//  SeedBackupPage.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/3/21.
//

import SwiftUI
import URUI
import WolfSwiftUI
import SwiftUIPrint

struct SeedBackupPage: View {
    let seed: ModelSeed
    
    var body: some View {
        BackupPage(subject: seed, footer: footer)
    }
    
    var footer: some View {
        Group {
            data
            byteWords
            bip39
            urView
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
                .minimumScaleFactor(0.5)
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
                .minimumScaleFactor(0.5)
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
            Text(seed.bip39.mnemonic)
                .monospaced()
                .minimumScaleFactor(0.5)
        }
    }
    
    var urLabel: some View {
        Label(
            title: { Text("UR").bold() },
            icon: { Image("ur.bar") }
        )
    }

    var urView: some View {
        VStack(alignment: .leading) {
            urLabel
            Text(seed.urString)
                .font(.system(size: 12, design: .monospaced))
                .minimumScaleFactor(0.2)
//                .fixedVertical()
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
    
    var truncatedNote: String? {
        let fullNote = seed.note
        guard
            !fullNote.isEmpty
        else {
            return nil
        }
        let note: String
        if fullNote.count <= 1000 {
            note = fullNote
        } else {
            note = fullNote.prefix(count: 1000) + "…"
        }
        return note
    }
    
    var note: some View {
        VStack(alignment: .leading) {
            if let note = truncatedNote {
                SeedDetail.notesLabel
                Text(note)
                    .minimumScaleFactor(0.3)
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
            .previewLayout(.fixed(width: 8.5 * pointsPerInch, height: 11 * pointsPerInch))
    }
}

#endif

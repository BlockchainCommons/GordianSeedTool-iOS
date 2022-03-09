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
import BCFoundation

let seedDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f
}()

struct SeedBackupPage: View {
    let seed: ModelSeed
    
    let titleFontSize = 16.0
    let textFontSize = 12.0
    let sectionSpacing = 12.0
    let itemSpacing = 5.0
    
    var body: some View {
        BackupPage(subject: seed, footer: footer)
    }
    
    var footer: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            data
            byteWords
            bip39
            urView
            if seed.creationDate != nil {
                creationDate
            }
            derivations
            BackupPageNoteSection(note: seed.note)
            Spacer()
        }
    }

    var data: some View {
        BackupPageSection(title: Text("Hex"), icon: Image.hex) {
            Text(seed.data.hex)
                .monospaced(size: textFontSize)
                .layoutPriority(1)
        }
    }

    var byteWords: some View {
        BackupPageSection(title: Text("ByteWords"), icon: Image.byteWords) {
            Text(seed.byteWords)
                .monospaced(size: textFontSize)
                .layoutPriority(1)
        }
    }

    var bip39: some View {
        BackupPageSection(title: Text("BIP39 Words"), icon: Image.bip39) {
            Text(seed.bip39.mnemonic)
                .monospaced(size: textFontSize)
                .layoutPriority(1)
        }
    }
    
    var urView: some View {
        BackupPageSection(title: Text("UR"), icon: Image.ur) {
            Text(seed.urString)
                .monospaced(size: textFontSize)
                .minimumScaleFactor(0.3)
        }
    }

    var creationDate: some View {
        BackupPageSection(title: Text("Creation Date"), icon: Image.date) {
            Text(seedDateFormatter.string(from: seed.creationDate!))
                .layoutPriority(1)
        }
    }
    
    var derivations: some View {
        BackupPageSection(title: Text("Derivations"), icon: Image.key) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Master Key Fingerprint: ").bold() + Text(masterKeyFingerprint.flanked("[", "]")).monospaced(size: textFontSize)
                Text("Ethereum Account: ").bold() + Text(ethereumAccount).monospaced(size: textFontSize)
            }
            .layoutPriority(1)
        }
    }
    
    var masterKey: HDKey {
        seed.masterKey
    }
    
    var masterKeyFingerprint: String {
        masterKey.keyFingerprintData.hex
    }
    
    var ethereumAccount: String {
        Ethereum.Address(hdKey: masterKey).description
    }
}

struct BackupPageLabel: View {
    let title: Text
    let icon: Image
    
    var body: some View {
        Label(title: { title }, icon: { icon })
            .font(.system(size: 16, weight: .bold))
    }
}

struct BackupPageSection<Content>: View where Content: View {
    let title: Text
    let icon: Image
    let content: () -> Content
    
    init(title: Text, icon: Image, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            BackupPageLabel(title: title, icon: icon)
            content()
                .font(.system(size: 12))
        }
    }
}

struct BackupPageNoteSection: View {
    let note: String
    
    var body: some View {
        if let note = sizeLimitedNote, !note.isEmpty {
            BackupPageSection(title: Text("Notes"), icon: Image.note) {
                Text(note)
                    .minimumScaleFactor(0.5)
                    .layoutPriority(0.5)
            }
        }
    }
    
    var sizeLimitedNote: String? {
        let fullNote = note.trim()
        guard
            !fullNote.isEmpty
        else {
            return nil
        }
        let note: String
        if fullNote.count <= appNoteLimit {
            note = fullNote
        } else {
            note = fullNote.prefix(count: appNoteLimit) + "…"
        }
        return note
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

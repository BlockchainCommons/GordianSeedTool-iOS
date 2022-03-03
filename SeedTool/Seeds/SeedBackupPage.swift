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
            if !seed.note.isEmpty {
                note
            }
            Spacer()
        }
    }

    var data: some View {
        section(title: Text("Hex"), icon: Image.hex) {
            Text(seed.data.hex)
                .monospaced(size: textFontSize)
                .layoutPriority(1)
        }
    }

    var byteWords: some View {
        section(title: Text("ByteWords"), icon: Image.byteWords) {
            Text(seed.byteWords)
                .monospaced(size: textFontSize)
                .layoutPriority(1)
        }
    }

    var bip39: some View {
        section(title: Text("BIP39 Words"), icon: Image.bip39) {
            Text(seed.bip39.mnemonic)
                .monospaced(size: textFontSize)
                .layoutPriority(1)
        }
    }
    
    var urView: some View {
        section(title: Text("UR"), icon: Image.ur) {
            Text(seed.urString)
                .monospaced(size: textFontSize)
                .minimumScaleFactor(0.3)
        }
    }

    var creationDate: some View {
        section(title: Text("Creation Date"), icon: Image.date) {
            Text(seedDateFormatter.string(from: seed.creationDate!))
                .layoutPriority(1)
        }
    }
    
    var derivations: some View {
        section(title: Text("Derivations"), icon: Image.key) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Master Key Fingerprint: ").bold() + Text(masterKeyFingerprint.flanked("[", "]")).monospaced(size: textFontSize)
                Text("Ethereum Account: ").bold() + Text(ethereumAccount).monospaced(size: textFontSize)
            }
            .layoutPriority(1)
        }
    }
    
    var note: some View {
        section(title: Text("Notes"), icon: Image.note) {
            Text(truncatedNote!)
                .minimumScaleFactor(0.5)
                .layoutPriority(0.5)
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
    
    var masterKey: HDKey {
        seed.masterKey
    }
    
    var masterKeyFingerprint: String {
        masterKey.keyFingerprintData.hex
    }
    
    var ethereumAccount: String {
        Ethereum.Address(hdKey: masterKey).description
    }

    func section<Content>(title: Text, icon: Image, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        VStack(alignment: .leading, spacing: itemSpacing) {
            label(title: title, icon: icon)
                //.debugRed()

            content()
                .font(.system(size: textFontSize))
                //.debugRed()
        }
        //.debugBlue()
    }
    
    func label(title: Text, icon: Image) -> some View {
        Label(title: { title }, icon: { icon })
            .font(.system(size: titleFontSize, weight: .bold))
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

//
//  SeedBackupPage.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/3/21.
//

import SwiftUI
import WolfSwiftUI
import SwiftUIPrint
import BCApp
import WolfBase

let seedDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f
}()

let backupPageTextFontSize = 12.0

fileprivate let titleFontSize = 16.0
fileprivate let dataFontSize = 8.0
fileprivate let sectionSpacing = 12.0
fileprivate let itemSpacing = 5.0

struct SeedBackupPage: View {
    let seed: ModelSeed
    
    var body: some View {
        BackupPage(subject: seed, footer: footer)
    }
    
    @ViewBuilder
    var footer: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            HStack(spacing: 30) {
                hex
                if hasCreationDate {
                    Spacer()
                    creationDate
                }
            }
            HStack(spacing: 30) {
                byteWords
                Spacer()
                bip39
            }
            envelopeView
                .layoutPriority(-1)
            if hasDerivation {
                derivations
            }
            if hasNote {
                BackupPageNoteSection(note: seed.note)
                    .layoutPriority(-1)
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var hex: some View {
        BackupPageSection(title: Text("Hex"), icon: Image.hex) {
            Text(seed.data.hex)
                .appMonospaced(size: dataFontSize)
        }
    }

    @ViewBuilder
    var byteWords: some View {
        BackupPageSection(title: Text("ByteWords"), icon: Image.byteWords) {
            Text(seed.byteWords)
                .appMonospaced(size: dataFontSize)
                .fixedVertical()
        }
    }

    @ViewBuilder
    var bip39: some View {
        BackupPageSection(title: Text("BIP39 Words"), icon: Image.bip39) {
            Text(seed.bip39.mnemonic)
                .appMonospaced(size: dataFontSize)
                .fixedVertical()
        }
    }
    
    @ViewBuilder
    var envelopeView: some View {
        BackupPageSection(title: Text("Envelope"), icon: Image.envelope) {
            Text(seed.envelope.urString)
                .appMonospaced(size: backupPageTextFontSize)
                .minimumScaleFactor(0.3)
        }
    }

    @ViewBuilder
    var creationDate: some View {
        BackupPageSection(title: Text("Creation Date"), icon: Image.date) {
            Text(seedDateFormatter.string(from: seed.creationDate!))
                .font(.system(size: dataFontSize))
        }
    }
    
    @ViewBuilder
    var btcDerivation: some View {
        if let outputDescriptor = seed.outputDescriptor {
            BackupPageSection(title: Text("Output Descriptor"), icon: Image.bitcoin) {
                HStack {
                    PrintingQRCodeView(message: outputDescriptor.sourceWithChecksum.utf8Data)
                        .frame(height: 50)
                    VStack(alignment: .leading) {
                        Text(outputDescriptor.sourceWithChecksum)
                            .appMonospaced(size: backupPageTextFontSize)
                    }
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    var ethDerivation: some View {
        BackupPageSection(title: Text("Ethereum Account"), icon: Image.ethereum) {
            HStack {
                PrintingQRCodeView(message: ethereumAccount.utf8Data)
                    .frame(height: 50)
                VStack(alignment: .leading) {
                    Text(ethereumAccount)
                        .appMonospaced(size: backupPageTextFontSize)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var xtzDerivation: some View {
        BackupPageSection(title: Text("Tezos Address"), icon: Image.tezos) {
            HStack {
                PrintingQRCodeView(message: tezosAddress.utf8Data)
                    .frame(height: 50)
                VStack(alignment: .leading) {
                    Text(tezosAddress)
                        .appMonospaced(size: backupPageTextFontSize)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var derivations: some View {
        VStack(alignment: .leading, spacing: 5) {
            switch globalSettings.primaryAsset {
            case .btc:
                btcDerivation
            case .eth:
                ethDerivation
            case .xtz:
                xtzDerivation
            }
        }
    }
    
    var hasDerivation: Bool {
        globalSettings.primaryAsset != .btc ||
        seed.outputDescriptor != nil
    }
    
    var hasCreationDate: Bool {
        seed.creationDate != nil
    }
    
    var hasNote: Bool {
        !seed.note.isEmpty
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
    
    var tezosAddress: String {
        Tezos.Address(hdKey: masterKey)!.description
    }
}

#if DEBUG

import WolfLorem

fileprivate let previewSeed = Lorem.seed()
#Preview(
    traits: .fixedLayout(width: pointsPerInch * 8.5, height: pointsPerInch * 11)
) {
    SeedBackupPage(seed: previewSeed)
        .lightMode()
}

#endif

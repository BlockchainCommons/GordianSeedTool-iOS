//
//  PrivateKeyBackupPage.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/18/21.
//

import SwiftUI
import BCFoundation

struct PrivateKeyBackupPage: View {
    let privateKey: ModelPrivateKey
    
    var body: some View {
        BackupPage(subject: privateKey, footer: footer)
    }
    
    var addressString: String {
        privateKey.derivations.ethereumAddress!.string
    }

    var footer: some View {
        Group {
            privateKeyView
            addressView
            parentSeedView
        }
    }
    
    var privateKeyLabel: some View {
        Label(
            title: { Text("Private Key").bold() },
            icon: { Image("key.fill.circle") }
        )
    }

    var privateKeyView: some View {
        VStack(alignment: .leading) {
            privateKeyLabel
            Text(privateKey.string)
                .minimumScaleFactor(0.5)
                .font(.system(size: 12, design: .monospaced))
                .fixedVertical()
        }
    }
    
    var addressView: some View {
        HStack {
            VStack(alignment: .leading) {
                addressLabel
                Text(addressString)
                    .minimumScaleFactor(0.5)
                    .font(.system(size: 12, design: .monospaced))
                    .fixedVertical()
            }
            Spacer()
            PrintingQRCodeView(message: addressString.utf8Data)
                .frame(height: pointsPerInch * 2.0)
        }
    }
    
    var addressLabel: some View {
        Label(
            title: { Text("Address").bold() },
            icon: { Image(systemName: "envelope.circle") }
        )
    }

    var parentSeedLabel: some View {
        Label(
            title: { Text("Parent Seed").bold() },
            icon: { Image("seed.circle") }
        )
    }
    
    var parentSeedView: some View {
        VStack(alignment: .leading) {
            if let parentSeed = privateKey.parentSeed {
                parentSeedLabel
                ObjectIdentityBlock(model: .constant(parentSeed), allowLongPressCopy: false, generateVisualHashAsync: false)
                    .frame(height: pointsPerInch * 1.25)
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct PrivateKeyBackupPage_Previews: PreviewProvider {
    static let seed: ModelSeed = {
        Lorem.seed()
    }()
    static let privateHDKey: ModelHDKey = {
        try! ModelHDKey(seed: seed)
    }()
    
    static let privateKey: ModelPrivateKey = {
        ModelPrivateKey(seed: seed, name: "Private Key from \(seed.name)", useInfo: UseInfo(asset: .eth, network: .mainnet))
    }()
    
    static var previews: some View {
        PrivateKeyBackupPage(privateKey: privateKey)
            .previewLayout(.fixed(width: 8.5 * pointsPerInch, height: 11 * pointsPerInch))
    }
}

#endif

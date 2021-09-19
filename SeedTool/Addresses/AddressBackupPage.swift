//
//  AddressBackupPage.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/17/21.
//

import SwiftUI
import LibWally

struct AddressBackupPage: View {
    let address: ModelAddress
    
    var body: some View {
        BackupPage(subject: address, footer: footer)
    }
    
    var privateKey: String {
        address.account.accountECPrivateKey!.data.hex
    }

    var footer: some View {
        Group {
            addressView
//            if address.showPrivateKey {
//                privateKeyView
//            }
            parentSeedView
        }
    }
    
    var addressLabel: some View {
        Label(
            title: { Text("Address").bold() },
            icon: { Image(systemName: "envelope.circle") }
        )
    }

    var addressView: some View {
        VStack(alignment: .leading) {
            addressLabel
            Text(address.string)
                .minimumScaleFactor(0.5)
                .font(.system(size: 12, design: .monospaced))
                .fixedVertical()
        }
    }
    
    var privateKeyView: some View {
        HStack {
            VStack(alignment: .leading) {
                privateKeyLabel
                Text(privateKey)
                    .minimumScaleFactor(0.5)
                    .font(.system(size: 12, design: .monospaced))
                    .fixedVertical()
            }
            Spacer()
            PrintingQRCodeView(message: privateKey.utf8Data)
                .frame(height: pointsPerInch * 2.0)
        }
    }
    
    var privateKeyLabel: some View {
        Label(
            title: { Text("Private Key").bold() },
            icon: { KeyType.private.icon }
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
            if let parentSeed = address.parentSeed {
                parentSeedLabel
                ObjectIdentityBlock(model: .constant(parentSeed), allowLongPressCopy: false, generateVisualHashAsync: false)
                    .frame(height: pointsPerInch * 1.25)
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct AddressBackupPage_Previews: PreviewProvider {
    static let seed: ModelSeed = {
        Lorem.seed()
    }()
    static let privateHDKey: HDKey = {
        HDKey(seed: seed)
    }()
    
    static let address: ModelAddress = {
        ModelAddress(seed: seed, name: "Address from \(seed.name)", useInfo: UseInfo(asset: .eth, network: .mainnet))
    }()
    
    static var previews: some View {
        AddressBackupPage(address: address)
            .previewLayout(.fixed(width: 8.5 * pointsPerInch, height: 11 * pointsPerInch))
    }
}

#endif

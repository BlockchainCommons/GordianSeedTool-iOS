//
//  AddressBackupPage.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/17/21.
//

import SwiftUI

struct AddressBackupPage: View {
    let address: ModelAddress
    
    var body: some View {
        BackupPage(subject: address, footer: footer)
    }
    
    var footer: some View {
        Group {
            addressView
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
    static let privateKey: HDKey = {
        HDKey(seed: seed)
    }()
    
    static var previews: some View {
        KeyBackupPage(key: privateKey, parentSeed: seed)
            .previewLayout(.fixed(width: 8.5 * pointsPerInch, height: 11 * pointsPerInch))
    }
}

#endif

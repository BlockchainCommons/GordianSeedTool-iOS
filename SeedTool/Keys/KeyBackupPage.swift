//
//  KeyBackupPage.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/11/21.
//

import SwiftUI

struct KeyBackupPage: View {
    let key: HDKey
    let parentSeed: Seed?
    
    var body: some View {
        BackupPage(subject: key, footer: footer)
    }
    
    var footer: some View {
        Group {
            urView
            parentSeedView
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
            if let parentSeed = parentSeed {
                parentSeedLabel
                ModelObjectIdentity(model: .constant(parentSeed), allowLongPressCopy: false, generateLifeHashAsync: false)
                    .frame(height: pointsPerInch * 1.25)
            }
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
            Text(key.urString)
                .minimumScaleFactor(0.5)
                .font(.system(size: 12, design: .monospaced))
                .fixedVertical()
        }
    }
}

#if DEBUG

import WolfLorem

struct KeyBackupPage_Previews: PreviewProvider {
    static let seed: Seed = {
        Lorem.seed()
    }()
    static let key: HDKey = {
        HDKey(seed: seed)
    }()
    
    static var previews: some View {
        KeyBackupPage(key: key, parentSeed: seed)
            .previewLayout(.fixed(width: 8.5 * pointsPerInch, height: 11 * pointsPerInch))
    }
}

#endif

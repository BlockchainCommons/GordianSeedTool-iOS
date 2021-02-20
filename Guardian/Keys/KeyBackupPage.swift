//
//  KeyBackupPage.swift
//  Guardian
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
            if let parentSeed = parentSeed {
                VStack(alignment: .leading) {
                    Label(
                        title: { Text("Parent Seed").bold() },
                        icon: { Image("seed.circle") }
                    )
                    ModelObjectIdentity(model: .constant(parentSeed), allowLongPressCopy: false, generateLifeHashAsync: false)
                        .frame(height: 72 * 1.25)
                }
            }
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
            .previewLayout(.fixed(width: 8.5 * 72, height: 11 * 82))
    }
}

#endif

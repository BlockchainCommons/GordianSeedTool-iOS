//
//  KeyBackupPage.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/11/21.
//

import SwiftUI
import WolfBase
import BCApp

struct KeyBackupPage: View {
    let key: ModelHDKey
    let parentSeed: ModelSeed?
    
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
            icon: { Image.seed }
        )
    }
    
    var parentSeedView: some View {
        VStack(alignment: .leading) {
            if let parentSeed = parentSeed {
                parentSeedLabel
                ObjectIdentityBlock(model: .constant(parentSeed), allowLongPressCopy: false, generateVisualHashAsync: false)
                    .frame(height: pointsPerInch * 1.25)
            }
        }
    }
    
    var urLabel: some View {
        Label(
            title: { Text("UR").bold() },
            icon: { Image.ur }
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
    static let seed: ModelSeed = {
        Lorem.seed()
    }()
    static let privateHDKey: ModelHDKey = {
        try! ModelHDKey(seed: seed)
    }()
    
    static var previews: some View {
        KeyBackupPage(key: privateHDKey, parentSeed: seed)
            .previewLayout(.fixed(width: 8.5 * pointsPerInch, height: 11 * pointsPerInch))
    }
}

#endif

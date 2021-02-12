//
//  BackupPage.swift
//  Guardian
//
//  Created by Wolf McNally on 2/11/21.
//

import SwiftUI
import URUI

struct BackupPageLifeHashHeightKey: PreferenceKey {
    static var defaultValue: CGFloat?
    
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
    }
}

struct BackupPage<Subject, Footer>: View where Subject: ModelObject, Footer: View {
    let subject: Subject
    let footer: Footer

    @State private var lifeHashHeight: CGFloat?
    let margins: CGFloat = 72 * 0.5

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0.25 * 72) {
                identity
                    .background(GeometryReader { p in
                        Color.clear
                            .preference(key: BackupPageLifeHashHeightKey.self, value: p.size.height)
                    })
                qrCode
                    .layoutPriority(0.5)
                    .frame(height: lifeHashHeight)
            }
            footer
            Spacer()
        }
        .padding(margins)
        .environment(\.sizeCategory, .extraLarge)
        .onPreferenceChange(BackupPageLifeHashHeightKey.self) {
            lifeHashHeight = $0
        }
    }
    
    var identity: some View {
        ModelObjectIdentity(model: .constant(subject), allowLongPressCopy: false, generateLifeHashAsync: false, lifeHashWeight: 0.6)
    }
    
    var qrCode: some View {
        let message = subject.sizeLimitedURString.uppercased().data(using: .utf8)!
        let uiImage = makeQRCodeImage(message, correctionLevel: .low)
        let scaledImage = uiImage.scaled(by: 8)
        return Image(uiImage: scaledImage)
            .renderingMode(.template)
            .interpolation(.none)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#if DEBUG

import WolfLorem

struct BackupPage_Previews: PreviewProvider {
    static let seed: Seed = { Lorem.seed() }()
    static let key: HDKey = { HDKey(seed: seed) }()
    
    static var previews: some View {
        BackupPage(subject: key, footer: EmptyView())
            .previewLayout(.fixed(width: 8.5 * 72, height: 11 * 82))
    }
}

#endif

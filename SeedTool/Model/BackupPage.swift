//
//  BackupPage.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/11/21.
//

import SwiftUI
import WolfBase
import BCApp

struct BackupPage<Subject, Footer>: View where Subject: ObjectIdentifiable, Footer: View {
    let subject: Subject
    let footer: Footer

    let margins: CGFloat = pointsPerInch * 0.5
    
    let qrString: String
    let didLimit: Bool
    
    init(subject: Subject, footer: Footer) {
        self.subject = subject
        self.footer = footer
        let (qrString, didLimit) = subject.sizeLimitedQRString
        self.qrString = qrString
        self.didLimit = didLimit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 0.25 * pointsPerInch) {
                identity
                Spacer()
                qrCode
            }
            .frame(height: pointsPerInch * 2.0)
            
            if didLimit {
                Caution("Some metadata was shortened to fit into the QR code. Try making your notes field smaller.")
                    .font(.system(size: 14))
            }

            footer

            Spacer()
        }
        .padding(margins)
        .environment(\.sizeCategory, .extraLarge)
    }
    
    var identity: some View {
        ObjectIdentityBlock(model: .constant(subject), allowLongPressCopy: false, generateVisualHashAsync: false, visualHashWeight: 0.5)
    }
    
    var qrCode: some View {
        return PrintingQRCodeView(message: qrString.utf8Data)
    }
}

struct PrintingQRCodeView: View {
    let message: Data
    
    var body: some View {
        let uiImage = makeQRCodeImage(message)
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
    static let seed: ModelSeed = { Lorem.seed() }()
    static let privateHDKey: ModelHDKey = { try! ModelHDKey(seed: seed) }()
    
    static var previews: some View {
        BackupPage(subject: seed, footer: EmptyView())
            .previewLayout(.fixed(width: 8.5 * pointsPerInch, height: 11 * pointsPerInch))
    }
}

#endif

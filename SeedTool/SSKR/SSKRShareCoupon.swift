//
//  SSKRShareCoupon.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/7/22.
//

import Foundation
import URKit
import UIKit
import URUI
import BCFoundation
import WolfBase

struct SSKRShareCoupon: Identifiable {
    let id = UUID()
    let date: Date
    let ur: UR
    let bytewords: String
    let seed: ModelSeed
    let groupIndex: Int
    let shareIndex: Int
    let sharesCount: Int
    @Lazy var qrCode: UIImage

    init(date: Date, ur: UR, bytewords: String, seed: ModelSeed, groupIndex: Int, shareIndex: Int, sharesCount: Int) {
        self.date = date
        self.ur = ur
        self.bytewords = bytewords
        self.seed = seed
        self.groupIndex = groupIndex
        self.shareIndex = shareIndex
        self.sharesCount = sharesCount
        self._qrCode = Lazy(wrappedValue: makeQRCodeImage(ur.qrData, correctionLevel: .low, backgroundColor: .white).scaled(by: 8))
    }
    
    var bytewordsBody: String {
        bytewords.split(separator: " ").dropLast(4).joined(separator: " ")
    }
    
    var bytewordsChecksum: String {
        bytewords.split(separator: " ").suffix(4).joined(separator: " ")
    }
    
    var name: String {
        bytewordsChecksum.uppercased()
    }
    
    var urString: String {
        ur.string
    }
    
    var nameActivityParams: ActivityParams {
        ActivityParams(
            name,
            name: name,
            fields: [
                .placeholder: name,
                .rootID: seed.digestIdentifier,
                .type: "SSKR",
                .subtype: subtypeString
            ]
        )
    }
    
    var bytewordsActivityParams: ActivityParams {
        ActivityParams(
            bytewords,
            name: name,
            fields: [
                .placeholder: "ByteWords for \(name)",
                .rootID: seed.digestIdentifier,
                .type: "SSKR",
                .subtype: subtypeString,
                .format: "ByteWords"
            ]
        )
    }
    
    var urActivityParams: ActivityParams {
        ActivityParams(
            urString,
            name: name,
            fields: [
                .placeholder: "UR for \(name)",
                .rootID: seed.digestIdentifier,
                .type: "SSKR",
                .subtype: subtypeString,
                .format: "UR"
            ]
        )
    }
    
    var qrCodeActivityParams: ActivityParams {
        ActivityParams(
            qrCode,
            name: name,
            fields: [
                .placeholder: "QR for \(name)",
                .rootID: seed.digestIdentifier,
                .type: "SSKR",
                .subtype: subtypeString,
                .format: "UR"
            ]
        )
    }
    
    var subtypeString: String {
        "group\(groupIndex + 1)-\(shareIndex + 1)of\(sharesCount)"
    }
}

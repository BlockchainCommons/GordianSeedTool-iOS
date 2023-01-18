//
//  SSKRShareCoupon.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/7/22.
//

import Foundation
import URKit
import UIKit
import WolfBase
import BCApp

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
        self._qrCode = Lazy(wrappedValue: makeQRCodeImage(ur.qrData, backgroundColor: .white).scaled(by: 8))
    }
    
    var bytewordsBody: String {
        bytewords.split(separator: " ").dropLast(4).joined(separator: " ")
    }
    
    var bytewordsChecksum: String {
        bytewords.split(separator: " ").suffix(4).joined(separator: " ").uppercased()
    }
    
    var name: String {
        bytewordsChecksum
    }
    
    var urString: String {
        ur.string
    }
    
    var nameActivityParams: ActivityParams {
        ActivityParams(
            name,
            name: name,
            fields: exportFields(placeholder: name)
        )
    }
    
    var bytewordsActivityParams: ActivityParams {
        ActivityParams(
            bytewords,
            name: name,
            fields: exportFields(
                placeholder: "ByteWords for \(name)",
                format: "ByteWords"
            )
        )
    }
    
    var urActivityParams: ActivityParams {
        ActivityParams(
            urString,
            name: name,
            fields: exportFields(
                placeholder: "UR for \(name)",
                format: "UR"
            )
        )
    }
    
    var qrCodeActivityParams: ActivityParams {
        ActivityParams(
            qrCode,
            name: name,
            fields: exportFields(
                placeholder: "QR for \(name)",
                format: "UR"
            )
        )
    }
    
    func exportFields(placeholder: String, format: String? = nil) -> ExportFields {
        var fields: ExportFields = [
            .placeholder: placeholder,
            .rootID: seed.digestIdentifier,
            .id: idString,
            .type: "SSKR",
        ]
        if let format = format {
            fields[.format] = format
        }
        return fields
    }
    
    var idString: String {
        "[group\(groupIndex + 1)_\(shareIndex + 1)of\(sharesCount)]"
    }
}

extension SSKRShareCoupon: Equatable {
    static func == (lhs: SSKRShareCoupon, rhs: SSKRShareCoupon) -> Bool {
        lhs.ur == rhs.ur
    }
}

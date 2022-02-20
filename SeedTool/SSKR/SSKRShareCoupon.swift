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
    let seed: SeedProtocol
    let groupIndex: Int
    @Lazy var qrCode: UIImage

    init(date: Date, ur: UR, bytewords: String, seed: SeedProtocol, groupIndex: Int) {
        self.date = date
        self.ur = ur
        self.bytewords = bytewords
        self.seed = seed
        self.groupIndex = groupIndex
        self._qrCode = Lazy(wrappedValue: makeQRCodeImage(ur.qrData, correctionLevel: .low, backgroundColor: .white).scaled(by: 8))
    }
    
    var bytewordsBody: String {
        bytewords.split(separator: " ").dropLast(4).joined(separator: " ")
    }
    
    var bytewordsChecksum: String {
        bytewords.split(separator: " ").suffix(4).joined(separator: " ")
    }
    
    var title: String {
        bytewordsChecksum.uppercased()
    }
    
    var urString: String {
        ur.string
    }
    
    var bytewordsActivityParams: ActivityParams {
        ActivityParams(bytewords, export: Export(name: "SSKR ByteWords \(title)"))
    }
    
    var urActivityParams: ActivityParams {
        ActivityParams(urString, export: Export(name: "SSKR UR \(title)"))
    }
    
    var qrCodeActivityParams: ActivityParams {
        ActivityParams(qrCode, export: Export(name: "SSKR QR \(title)"))
    }
}

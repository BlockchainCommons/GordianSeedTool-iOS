//
//  SSKRShareCoupon.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/7/22.
//

import Foundation
import URKit
import BCFoundation

struct SSKRShareCoupon: Identifiable {
    let id = UUID()
    let date: Date
    let ur: UR
    let bytewords: String
    let seed: SeedProtocol
    let groupIndex: Int
    
    var bytewordsBody: String {
        bytewords.split(separator: " ").dropLast(4).joined(separator: " ")
    }
    
    var bytewordsChecksum: String {
        bytewords.split(separator: " ").suffix(4).joined(separator: " ")
    }
}

//
//  CoinType.swift
//  Guardian
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import URKit

enum CoinType: Int {
    // Values from [SLIP44] with high bit turned off
    case btc = 0
    case eth = 0x3c
    
    var cbor: CBOR {
        CBOR.unsignedInt(UInt64(rawValue))
    }
    
    init(cbor: CBOR) throws {
        guard
            case let CBOR.unsignedInt(r) = cbor,
            let a = CoinType(rawValue: Int(r)) else {
            throw GeneralError("Invalid CoinType.")
        }
        self = a
    }
}

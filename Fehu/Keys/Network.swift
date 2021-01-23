//
//  Network.swift
//  Guardian
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import URKit
import LibWally

enum Network: Int {
    case mainnet = 0
    case testnet = 1
    
    var cbor: CBOR {
        CBOR.unsignedInt(UInt64(rawValue))
    }
    
    init(cbor: CBOR) throws {
        guard
            case let CBOR.unsignedInt(r) = cbor,
            let a = Network(rawValue: Int(r)) else {
            throw GeneralError("Invalid Network.")
        }
        self = a
    }
    
    var wallyNetwork: LibWally.Network {
        switch self {
        case .mainnet:
            return .mainnet
        case .testnet:
            return .testnet
        }
    }
}

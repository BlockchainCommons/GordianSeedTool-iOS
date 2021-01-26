//
//  UseInfo.swift
//  Guardian
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import URKit

// https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-007-hdkey.md#cddl-for-coin-info
struct UseInfo {
    let asset: Asset?
    let network: Network?

    init(asset: Asset? = nil, network: Network? = nil) {
        self.asset = asset
        self.network = network
    }
        
    var cbor: CBOR {
        var a: [OrderedMapEntry] = []
        
        if let asset = asset {
            a.append(.init(key: 1, value: asset.cbor))
        }
        
        if let network = network {
            a.append(.init(key: 2, value: network.cbor))
        }
        
        return CBOR.orderedMap(a)
    }
    
    var taggedCBOR: CBOR {
        CBOR.tagged(.init(rawValue: 305), cbor)
    }

    init(cbor: CBOR) throws {
        guard case let CBOR.map(pairs) = cbor else {
            throw GeneralError("Invalid CoinInfo.")
        }
        
        let asset: Asset?
        if let rawAsset = pairs[1] {
            asset = try Asset(cbor: rawAsset)
        } else {
            asset = nil
        }
        
        let network: Network?
        if let rawNetwork = pairs[2] {
            network = try Network(cbor: rawNetwork)
        } else {
            network = nil
        }
        
        self.init(asset: asset, network: network)
    }
    
    init(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.init(rawValue: 305), cbor) = taggedCBOR else {
            throw GeneralError("CoinInfo tag (305) not found.")
        }
        try self.init(cbor: cbor)
    }
}

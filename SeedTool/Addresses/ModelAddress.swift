//
//  ModelAddress.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/16/21.
//

import Foundation
import LibWally
import SwiftUI

extension Address {
    convenience init(key: HDKey, type: Address.AddressType) {
        self.init(hdKey: key.wallyHDKey, type: type)
    }
}

extension LibWally.HDKey {
    init(key: HDKey) {
        self.init(key: key.wallyHDKey.wallyExtKey, parent: .init(), children: key.children?.wallyDerivationPath ?? .init())
    }
}

final class ModelAddress: ObjectIdentifiable {
    let string: String
    var name: String
    let useInfo: UseInfo
    let parentSeed: ModelSeed?

    init(string: String, name: String, useInfo: UseInfo, parentSeed: ModelSeed? = nil) {
        self.string = string
        self.name = name
        self.useInfo = useInfo
        self.parentSeed = parentSeed
    }
    
    convenience init(key: HDKey, name: String, useInfo: UseInfo, parentSeed: ModelSeed? = nil) {
        let string: String
        switch useInfo.asset {
        case .btc:
            string = Address(key: key, type: .payToWitnessPubKeyHash).string
        case .eth:
            let k = LibWally.HDKey(key: key)
            let account = Ethereum.Account(masterKey: k)
            string = account.address!
        @unknown default:
            string = "unknown"
        }
        self.init(string: string, name: name, useInfo: useInfo, parentSeed: parentSeed)
    }

    var modelObjectType: ModelObjectType {
        .address
    }
    
    var sizeLimitedQRString: String {
        let prefix: String
        switch useInfo.asset {
        case .btc:
            prefix = "bitcoin"
        case .eth:
            prefix = "ethereum"
        @unknown default:
            prefix = "unknown"
        }
        return "\(prefix):\(string)"
    }
    
    var subtypes: [ModelSubtype] {
        [ useInfo.asset.subtype, useInfo.network.subtype ]
    }
    
    var instanceDetail: String? {
        string
    }
    
    var fingerprintData: Data {
        string.utf8Data
    }
    
    static func == (lhs: ModelAddress, rhs: ModelAddress) -> Bool {
        lhs.string == rhs.string
    }
    
    var visualHashType: VisualHashType {
        switch useInfo.asset {
        case .eth:
            return .blockies
        default:
            return .lifeHash
        }
    }
    
    func printPages(model: Model) -> [AnyView] {
        [
            AddressBackupPage(address: self)
                .eraseToAnyView()
        ]
    }
}

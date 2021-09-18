//
//  ModelAddress.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/16/21.
//

import Foundation
import LibWally
import SwiftUI
import WolfBase

extension Bitcoin.Address {
    convenience init(key: HDKey, type: AddressType) {
        self.init(hdKey: key.wallyHDKey, type: type)
    }
}

extension LibWally.HDKey {
    init(key: HDKey) {
        self.init(key: key.wallyHDKey.wallyExtKey, parent: .init(), children: key.children?.wallyDerivationPath ?? .init())
    }
}

extension LibWally.Account {
    convenience init(masterKey: HDKey, useInfo: UseInfo, account: UInt32) {
        self.init(masterKey: LibWally.HDKey(key: masterKey), useInfo: useInfo, account: account)
    }
}

final class ModelAddress: ObjectIdentifiable {
    var name: String
    let account: Account
    let parentSeed: ModelSeed?

    var string: String {
        let result: String
        switch account.useInfo.asset {
        case .btc:
            result = account.bitcoinAddress(type: .payToWitnessPubKeyHash)!.string
        case .eth:
            result = account.ethereumAddress!.string
        @unknown default:
            result = "unknown"
        }
        return result
    }

    init(masterKey: HDKey, name: String, useInfo: UseInfo, parentSeed: ModelSeed? = nil, account accountNum: UInt32 = 0) {
        self.name = name
        self.parentSeed = parentSeed

        let derivationPath = useInfo.accountDerivationPath(account: accountNum)
        let wallyMasterKey = LibWally.HDKey(key: masterKey.wallyExtKey, parent: .init(), children: derivationPath)
        self.account = Account(masterKey: wallyMasterKey, useInfo: useInfo, account: accountNum)
    }
    
    convenience init(seed: ModelSeed, name: String, useInfo: UseInfo, account accountNum: UInt32 = 0) {
        let masterKey = HDKey(seed: seed, useInfo: useInfo)
        self.init(masterKey: masterKey, name: name, useInfo: useInfo, parentSeed: seed, account: accountNum)
    }

    var modelObjectType: ModelObjectType {
        .address
    }
    
    var useInfo: UseInfo {
        account.useInfo
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

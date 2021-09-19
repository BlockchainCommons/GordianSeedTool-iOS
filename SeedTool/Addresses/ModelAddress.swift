//
//  ModelAddress.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/16/21.
//

import LibWally
import SwiftUI

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

    init(masterKey: HDKey, derivationPath: DerivationPath? = nil, name: String, useInfo: UseInfo, parentSeed: ModelSeed? = nil, account accountNum: UInt32 = 0) {
        self.name = name
        self.parentSeed = parentSeed

        let effectiveDerivationPath = derivationPath?.wallyDerivationPath ?? useInfo.accountDerivationPath(account: accountNum)
        let wallyMasterKey = LibWally.HDKey(key: masterKey.wallyExtKey, parent: .init(), children: effectiveDerivationPath)
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
        let prefix: String = ""
//        switch useInfo.asset {
//        case .btc:
//            prefix = "bitcoin:"
//        default:
//            prefix = ""
//        }
        return "\(prefix)\(string)"
    }
    
    var subtypes: [ModelSubtype] {
        [ useInfo.asset.subtype, useInfo.network.subtype ]
    }
    
    var fingerprintData: Data {
        string.utf8Data
    }
    
    var instanceDetail: String? {
        string
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

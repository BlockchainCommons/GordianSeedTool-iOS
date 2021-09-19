//
//  ModelPrivateKey.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/18/21.
//

import LibWally
import SwiftUI

final class ModelPrivateKey: ObjectIdentifiable {
    var name: String
    let account: Account
    let parentSeed: ModelSeed?

    var string: String {
        account.accountECPrivateKey!.hex
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
        .privateECKey
    }
    
    var useInfo: UseInfo {
        account.useInfo
    }
    
    var sizeLimitedQRString: String {
        string
    }
    
    var subtypes: [ModelSubtype] {
        [ useInfo.asset.subtype, useInfo.network.subtype ]
    }
    
    var fingerprintData: Data {
        switch useInfo.asset {
        case .btc:
            return string.utf8Data
        case .eth:
            return account.ethereumAddress!.string.utf8Data
        @unknown default:
            fatalError()
        }
    }
    
    static func == (lhs: ModelPrivateKey, rhs: ModelPrivateKey) -> Bool {
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
            PrivateKeyBackupPage(privateKey: self)
                .eraseToAnyView()
        ]
    }
}

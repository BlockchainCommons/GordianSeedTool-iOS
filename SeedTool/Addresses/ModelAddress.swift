//
//  ModelAddress.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/16/21.
//

import BCFoundation
import SwiftUI

final class ModelAddress: ObjectIdentifiable {
    var name: String
    let derivations: AccountDerivations
    let parentSeed: ModelSeed?

    var string: String {
        let result: String
        switch derivations.useInfo.asset {
        case .btc:
            result = derivations.bitcoinAddress(type: .payToWitnessPubKeyHash)!.string
        case .eth:
            result = derivations.ethereumAddress!.string
        }
        return result
    }
    
    var exportFields: ExportFields {
        var fields: ExportFields = [
            .placeholder: "Address from \(name)",
            .type: "Address"
        ]
        if let parentSeed = parentSeed {
            fields[.rootID] = parentSeed.digestIdentifier
        }
        return fields
    }

    init(masterKey: ModelHDKey, derivationPath: DerivationPath? = nil, name: String, useInfo: UseInfo, parentSeed: ModelSeed? = nil, account accountNum: UInt32 = 0) {
        self.name = name
        self.parentSeed = parentSeed

        let effectiveDerivationPath = derivationPath ?? useInfo.accountDerivationPath(account: accountNum)
        let masterKey = try! HDKey(key: masterKey, children: effectiveDerivationPath)
        self.derivations = AccountDerivations(masterKey: masterKey, useInfo: useInfo, account: accountNum)
    }
    
    convenience init(seed: ModelSeed, name: String, useInfo: UseInfo, account accountNum: UInt32 = 0) {
        let masterKey = try! ModelHDKey(seed: seed, useInfo: useInfo)
        self.init(masterKey: masterKey, name: name, useInfo: useInfo, parentSeed: seed, account: accountNum)
    }

    var modelObjectType: ModelObjectType {
        .address
    }
    
    var useInfo: UseInfo {
        derivations.useInfo
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

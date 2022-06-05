//
//  ModelAddress.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/16/21.
//

import BCFoundation
import SwiftUI
import BCApp

final class ModelAddress: ObjectIdentifiable, Printable {
    var name: String
    let derivations: AccountDerivations
    let masterKey: ModelHDKey
    
    var seed: ModelSeed {
        masterKey.seed
    }

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
    
    var accountKey: ModelHDKey {
        ModelHDKey(key: derivations.accountKey!, seed: masterKey.seed, name: masterKey.name)
    }
    
    var exportFields: ExportFields {
        [
            .placeholder: string,
            .rootID: seed.digestIdentifier,
            .id: accountKey.digestIdentifier,
            .subtype: accountKey.subtypeString,
            .type: "Address"
        ]
    }
    
    var printExportFields: ExportFields {
        exportFields
    }

    init(masterKey: ModelHDKey, derivationPath: DerivationPath? = nil, name: String, useInfo: UseInfo, parentSeed: ModelSeed? = nil, account accountNum: UInt32 = 0) {
        self.name = "Address from \(name)"
        self.masterKey = masterKey

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
    
    var sizeLimitedQRString: (String, Bool) {
        (string, false)
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
    
    var printPages: [AnyView] {
        [
            AddressBackupPage(address: self)
                .eraseToAnyView()
        ]
    }
}

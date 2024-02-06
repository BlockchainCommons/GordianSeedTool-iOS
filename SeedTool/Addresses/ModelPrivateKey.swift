//
//  ModelPrivateKey.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/18/21.
//

import SwiftUI
import BCApp

final class ModelPrivateKey: ObjectIdentifiable, Printable {
    var name: String
    let masterKey: ModelHDKey
    let derivations: AccountDerivations

    var string: String {
        switch useInfo.asset {
        case .btc:
            return derivations.accountECPrivateKey!.hex
        case .eth:
            return derivations.accountECPrivateKey!.hex
        case .xtz:
            return derivations.accountECPrivateKey!.tezos1Format
        }
    }
    
    var seed: ModelSeed {
        masterKey.seed
    }

    init(masterKey: ModelHDKey, derivationPath: DerivationPath? = nil, name: String, useInfo: UseInfo, account accountNum: UInt32 = 0) {
        self.name = name

        let effectiveDerivationPath = derivationPath ?? useInfo.accountDerivationPath(account: accountNum)
        let key = try! HDKey(key: masterKey, children: effectiveDerivationPath)
        self.derivations = AccountDerivations(masterKey: key, useInfo: useInfo, account: accountNum)
        self.masterKey = masterKey
    }
    
    convenience init(seed: ModelSeed, name: String, useInfo: UseInfo, account accountNum: UInt32 = 0) {
        let masterKey = try! ModelHDKey(seed: seed, useInfo: useInfo)
        self.init(masterKey: masterKey, name: name, useInfo: useInfo, account: accountNum)
    }
    
    var exportFields: ExportFields {
        switch useInfo.asset {
        case .btc:
            return keyExportFields(format: "Hex")
        case .eth:
            return keyExportFields(format: "Hex")
        case .xtz:
            return keyExportFields(format: "XTZ")
        }
    }
    
    var printExportFields: ExportFields {
        keyExportFields()
    }
    
    func keyExportFields(format: String? = nil) -> ExportFields {
        var fields: ExportFields = [
            .placeholder: name,
            .rootID: seed.digestIdentifier,
            .id: masterKey.digestIdentifier,
            .type: typeString,
            .subtype: ModelHDKey(derivations.accountKey!).subtypeString
        ]
        if let format = format {
            fields[.format] = format
        }
        return fields
    }

    var modelObjectType: ModelObjectType {
        .privateECKey
    }
    
    var useInfo: UseInfo {
        derivations.useInfo
    }
    
    var sizeLimitedQRString: (String, Bool) {
        (string, false)
    }
    
    var subtypes: [ModelSubtype] {
        useInfo.subtypes
    }
    
    var fingerprintData: Data {
        switch useInfo.asset {
        case .btc:
            return string.utf8Data
        case .eth:
            return derivations.ethereumAddress!.string.utf8Data
        case .xtz:
            return derivations.tezosAddress!.string.utf8Data
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
    
    var printPages: [AnyView] {
        [
            PrivateKeyBackupPage(privateKey: self)
                .eraseToAnyView()
        ]
    }
}

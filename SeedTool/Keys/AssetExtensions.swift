//
//  AssetExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import SwiftUI
import URKit
import LibWally

extension Asset {
    var cbor: CBOR {
        CBOR.unsignedInt(UInt64(rawValue))
    }
    
    init(cbor: CBOR) throws {
        guard
            case let CBOR.unsignedInt(r) = cbor,
            let a = Asset(rawValue: UInt32(r)) else {
            throw GeneralError("Invalid Asset.")
        }
        self = a
    }
    
    var icon: AnyView {
        switch self {
        case .btc:
            return Image("asset.btc")
                .renderingMode(.original)
                .accessibility(label: Text(self.name))
                .eraseToAnyView()
        case .eth:
            return Image("asset.eth")
                .renderingMode(.original)
                .accessibility(label: Text(self.name))
                .eraseToAnyView()
//        case .bch:
//            return Image("asset.bch").renderingMode(.original).eraseToAnyView()
        @unknown default:
            fatalError()
        }
    }
    
    var subtype: ModelSubtype {
        ModelSubtype(id: id, icon: icon)
    }
    
    var derivations: [KeyExportDerivationPreset] {
        switch self {
        case .btc:
            return [.master, .cosigner, .segwit, .custom]
        case .eth:
            return [.master, .ethereum, .custom]
        @unknown default:
            fatalError()
        }
    }
    
    var defaultDerivation: KeyExportDerivationPreset {
        switch self {
        case .btc:
            return .master
        case .eth:
            return .ethereum
        @unknown default:
            fatalError()
        }
    }
}

extension Asset: Segment {
    var label: AnyView {
        makeSegmentLabel(title: name, icon: icon)
    }
}

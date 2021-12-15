//
//  AssetExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import SwiftUI
import BCFoundation

extension Asset {
    var image: AnyView {
        switch self {
        case .btc:
            return Symbol.assetBTC
        case .eth:
            return Symbol.assetETH
        }
    }

    var icon: AnyView {
        image
            .accessibility(label: Text(self.name))
            .eraseToAnyView()
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
        }
    }
    
    var defaultDerivation: KeyExportDerivationPreset {
        switch self {
        case .btc:
            return .master
        case .eth:
            return .ethereum
        }
    }
}

extension Asset: Segment {
    var label: AnyView {
        makeSegmentLabel(title: name, icon: icon)
    }
}

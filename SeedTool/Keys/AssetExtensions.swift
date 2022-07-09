//
//  AssetExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import SwiftUI
import BCApp

extension Asset {
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
    public var label: AnyView {
        makeSegmentLabel(title: name, icon: icon.eraseToAnyView())
    }
}

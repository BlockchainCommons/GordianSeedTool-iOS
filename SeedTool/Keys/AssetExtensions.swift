//
//  AssetExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import SwiftUI
import BCFoundation

extension Asset {
    var image: some View {
        @ViewBuilder
        get {
            switch self {
            case .btc:
                Symbol.bitcoin
            case .eth:
                Symbol.ethereum
            }
        }
    }

    var icon: some View {
        @ViewBuilder
        get {
            image
                .accessibility(label: Text(self.name))
        }
    }
    
    var subtype: ModelSubtype {
        ModelSubtype(id: id, icon: icon.eraseToAnyView())
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
        makeSegmentLabel(title: name, icon: icon.eraseToAnyView())
    }
}

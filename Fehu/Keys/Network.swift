//
//  Network.swift
//  Guardian
//
//  Created by Wolf McNally on 1/22/21.
//

import SwiftUI
import URKit
import LibWally

enum Network: UInt32, Identifiable, CaseIterable {
    case mainnet = 0
    case testnet = 1
    
    var cbor: CBOR {
        CBOR.unsignedInt(UInt64(rawValue))
    }
    
    init(cbor: CBOR) throws {
        guard
            case let CBOR.unsignedInt(r) = cbor,
            let a = Network(rawValue: UInt32(r)) else {
            throw GeneralError("Invalid Network.")
        }
        self = a
    }
    
    var wallyNetwork: LibWally.Network {
        switch self {
        case .mainnet:
            return .mainnet
        case .testnet:
            return .testnet
        }
    }
    
    var icon: AnyView {
        switch self {
        case .mainnet:
            return Image("network.main").eraseToAnyView()
        case .testnet:
            return Image("network.test").eraseToAnyView()
        }
    }
    
    var name: String {
        switch self {
        case .mainnet:
            return "MainNet"
        case .testnet:
            return "TestNet"
        }
    }
    
    var iconWithName: some View {
        HStack {
            icon
            Text(name)
        }
    }
    
    var id: String {
        "network-\(description)"
    }

    var subtype: ModelSubtype {
        ModelSubtype(id: id, icon: icon)
    }
}

extension Network: Segment {
    var label: AnyView {
        makeSegmentLabel(title: name, icon: icon)
    }
}

extension Network: CustomStringConvertible {
    var description: String {
        switch self {
        case .mainnet:
            return "main"
        case .testnet:
            return "test"
        }
    }
}

//
//  NetworkExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import SwiftUI
import URKit
import LibWally

extension Network {
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
    
    var image: Image {
        switch self {
        case .mainnet:
            return Image("network.main")
        case .testnet:
            return Image("network.test")
        @unknown default:
            fatalError()
        }
    }
    
    var icon: AnyView {
        image
            .accessibility(label: Text(self.name))
            .eraseToAnyView()
    }
    
    var name: String {
        switch self {
        case .mainnet:
            return "MainNet"
        case .testnet:
            return "TestNet"
        @unknown default:
            fatalError()
        }
    }
    
    var textSuffix: Text {
        return Text(" ") + Text(image)
    }
    
    var iconWithName: some View {
        HStack {
            icon
            Text(name)
        }
    }
    
    init?(id: String) {
        switch id {
        case "network-main":
            self = .mainnet
        case "network-test":
            self = .testnet
        default:
            return nil
        }
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

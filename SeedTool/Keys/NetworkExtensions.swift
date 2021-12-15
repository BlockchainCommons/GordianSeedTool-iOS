//
//  NetworkExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import SwiftUI
import BCFoundation

extension Network {
    var image: Image {
        switch self {
        case .mainnet:
            return Image("network.main")
        case .testnet:
            return Image("network.test")
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

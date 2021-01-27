//
//  KeyExportDerivation.swift
//  Guardian
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

enum KeyExportDerivation: Identifiable, CaseIterable {
    case master
    case bip48
    
    var name: String {
        switch self {
        case .master:
            return "Master Key"
        case .bip48:
            return "BIP-48"
        }
    }
    
    var id: String {
        "derivation-\(description)"
    }
}

extension KeyExportDerivation: CustomStringConvertible {
    var description: String {
        switch self {
        case .master:
            return "master"
        case .bip48:
            return "bip48"
        }
    }
}

extension KeyExportDerivation: Segment {
    var label: AnyView {
        Text(name)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .eraseToAnyView()
    }
}

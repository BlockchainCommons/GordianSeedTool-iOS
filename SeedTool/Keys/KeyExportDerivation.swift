//
//  KeyExportDerivation.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

enum KeyExportDerivation: Identifiable, CaseIterable {
    case gordian
    case master
    
    var name: String {
        switch self {
        case .gordian:
            return "Gordian"
        case .master:
            return "Master Key"
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
        case .gordian:
            return "gordian"
        }
    }
}

extension KeyExportDerivation: Segment {
    var label: AnyView {
        switch self {
        case .master:
            return Text(name)
                .eraseToAnyView()
        case .gordian:
            return makeSegmentLabel(title: name, icon: Image("bc-logo").eraseToAnyView())
                .eraseToAnyView()
        }
    }
}

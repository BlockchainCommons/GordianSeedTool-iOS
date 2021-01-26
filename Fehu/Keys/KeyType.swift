//
//  KeyType.swift
//  Guardian
//
//  Created by Wolf McNally on 1/24/21.
//

import SwiftUI

enum KeyType: Identifiable, CaseIterable {
    case `private`
    case `public`
    
    var id: String {
        switch self {
        case .private:
            return "keytype-private"
        case .public:
            return "keytype-public"
        }
    }
    
    var icon: AnyView {
        switch self {
        case .private:
            return Image("key.prv.circle").eraseToAnyView()
        case .public:
            return Image("key.pub.circle").eraseToAnyView()
        }
    }
    
    var name: String {
        switch self {
        case .private:
            return "Private"
        case .public:
            return "Public"
        }
    }
}

extension KeyType: Segment {
    var label: AnyView {
        makeSegmentLabel(title: name, icon: icon)
    }
}

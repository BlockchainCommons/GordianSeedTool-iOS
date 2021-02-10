//
//  ModelObjectType.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

enum ModelObjectType {
    case seed
    case privateKey
    case publicKey

    var icon: AnyView {
        switch self {
        case .seed:
            return Image("seed.circle").icon().eraseToAnyView()
        case .privateKey:
            return KeyType.private.icon
        case .publicKey:
            return KeyType.public.icon
        }
    }
}

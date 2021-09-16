//
//  ModelObjectType.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

enum ModelObjectType {
    case seed
    case privateKey
    case publicKey
    case address

    var icon: AnyView {
        switch self {
        case .seed:
            return Image("seed.circle").icon().eraseToAnyView()
        case .privateKey:
            return KeyType.private.icon
        case .publicKey:
            return KeyType.public.icon
        case .address:
            return Image(systemName: "envelope.circle").icon().eraseToAnyView()
        }
    }
    
    var name: String {
        switch self {
        case .seed:
            return "Seed"
        case .privateKey:
            return "Private Key"
        case .publicKey:
            return "Public Key"
        case .address:
            return "Address"
        }
    }
}

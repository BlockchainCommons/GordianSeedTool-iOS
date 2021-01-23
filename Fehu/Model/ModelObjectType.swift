//
//  ModelObjectType.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

enum ModelObjectType {
    case seed
    case privateKey
    case publicKey

    var image: Image {
        switch self {
        case .seed:
            return Image("seed.circle")
        case .privateKey:
            return Image("key.prv.circle")
        case .publicKey:
            return Image("key.pub.circle")
        }
    }
}

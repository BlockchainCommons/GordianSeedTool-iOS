//
//  ModelObjectType.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

enum ModelObjectType {
    case seed

    var image: Image {
        switch self {
        case .seed:
            return Image("seed.circle")
        }
    }
}

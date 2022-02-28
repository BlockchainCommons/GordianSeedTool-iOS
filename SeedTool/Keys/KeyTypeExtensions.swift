//
//  KeyType.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/24/21.
//

import SwiftUI
import BCFoundation

extension KeyType {
    var icon: AnyView {
        switch self {
        case .private:
            return Image.privateKey
                .icon()
                .foregroundColor(.black)
                .encircle(color: .lightRedBackground)
                .eraseToAnyView()
        case .public:
            return Image.publicKey
                .icon()
                .foregroundColor(.white)
                .encircle(color: Color.darkGreenBackground)
                .eraseToAnyView()
        }
    }
}

extension KeyType: Segment {
    var label: AnyView {
        makeSegmentLabel(title: name, icon: icon)
    }
}

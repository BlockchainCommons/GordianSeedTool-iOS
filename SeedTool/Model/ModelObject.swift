//
//  ModelObject.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/15/20.
//

import SwiftUI
import LifeHash
import BCFoundation
import BCApp

protocol HasUR {
    var ur: UR { get }
    var qrData: Data { get }
}

protocol ModelObject: ObjectIdentifiable, Identifiable, ObservableObject, Hashable, HasUR {
    var sizeLimitedUR: (UR, Bool) { get }
    var urString: String { get }
    var id: UUID { get }
}

extension ModelObject {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension ModelObject {
    var subtypes: [ModelSubtype] { [] }
    var instanceDetail: String? { nil }
    var printPages: [AnyView] {
        [
            Text("No print page provided.")
                .eraseToAnyView()
        ]
    }

    var urString: String {
        ur.string
    }
    
    var qrData: Data {
        ur.qrData
    }
    
//    var sizeLimitedUR: (UR, Bool) {
//        (ur, false)
//    }
    
    var sizeLimitedQRString: (String, Bool) {
        let (ur, didLimit) = sizeLimitedUR
        return (UREncoder.encode(ur).uppercased(), didLimit)
    }
}

//
//  ModelObject.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/15/20.
//

import SwiftUI
import BCApp

protocol ModelObject: ObjectIdentifiable, Identifiable, ObservableObject, Hashable {
    var sizeLimitedEnvelope: (Envelope, Bool) { get }
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
    var instanceDetail: String? { nil }
    var printPages: [AnyView] {
        [
            Text("No print page provided.")
                .eraseToAnyView()
        ]
    }
    
//    var qrData: Data {
//        ur.qrData
//    }
    
    var sizeLimitedQRString: (String, Bool) {
        let (envelope, didLimit) = sizeLimitedEnvelope
        return (UREncoder.encode(envelope.ur).uppercased(), didLimit)
    }
}

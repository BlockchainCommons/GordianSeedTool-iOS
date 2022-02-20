//
//  ObjectIdentifiable.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/20/22.
//

import Foundation
import LifeHash

protocol ObjectIdentifiable: Fingerprintable, Printable {
    var modelObjectType: ModelObjectType { get }
    var name: String { get set }
    var subtypes: [ModelSubtype] { get }
    var instanceDetail: String? { get }
    var sizeLimitedQRString: String { get }
    var visualHashType: VisualHashType { get }
}

extension ObjectIdentifiable {
    var visualHashType: VisualHashType {
        .lifeHash
    }
    
    var instanceDetail: String? {
        nil
    }
}

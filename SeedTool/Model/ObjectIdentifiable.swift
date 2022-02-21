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
    var visualHashType: VisualHashType { get }
    var digestIdentifier: String { get }
    var typeString: String { get }
    var exportFields: ExportFields { get }
    var sizeLimitedQRString: (String, Bool) { get }
}

extension ObjectIdentifiable {
    var visualHashType: VisualHashType {
        .lifeHash
    }
    
    var instanceDetail: String? {
        nil
    }
    
    var digestIdentifier: String {
        fingerprint.identifier()
    }
    
    var typeString: String {
        modelObjectType.type
    }
    
    var exportFields: ExportFields {
        [:]
    }
    
    var printExportFields: ExportFields {
        exportFields
    }
}

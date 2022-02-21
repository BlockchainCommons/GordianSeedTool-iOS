//
//  Export.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/20/22.
//

import Foundation

typealias ExportFields = [Export.Field: String]

struct Export {
    private let name: String
    private let fields: ExportFields
    
    enum Field {
        case placeholder
        case rootID
        case id
        case type
        case subType
        case format
    }
    
    init(name: String, fields: ExportFields? = nil) {
        self.name = name
        self.fields = fields ?? [:]
    }
    
    var filename: String {
        [
            fields[.rootID],
            fields[.id],
            name,
            fields[.type],
            fields[.subType],
            fields[.format],
        ]
            .compactMap { $0 }
            .joined(separator: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    var placeholder: String {
        fields[.placeholder] ?? filename
    }
}

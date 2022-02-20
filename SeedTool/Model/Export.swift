//
//  Export.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/20/22.
//

import Foundation

struct Export {
    let id: String?
    let name: String
    let type: String?
    let format: String?
    
    init(id: String? = nil, name: String, type: String? = nil, format: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.format = format
    }
    
    var filename: String {
        [id, name, type, format]
            .compactMap { $0 }
            .joined(separator: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}

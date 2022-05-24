//
//  URLExtensions.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/12/21.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
    static var psbt = UTType("com.blockchaincommons.psbt")!
}

extension URL {
    var isPSBT: Bool {
        (try? resourceValues(forKeys: [.contentTypeKey]).contentType?.conforms(to: .psbt)) ?? false
    }
}

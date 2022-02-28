//
//  StringExtensions.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/27/22.
//

import Foundation

extension String {
    public func convertNonwordToSpace() -> String {
        String(map { $0.isLetter ? $0 : " " })
    }
}

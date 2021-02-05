//
//  StringExtensions.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/23/20.
//

import Foundation

extension String {
    func trim() -> String { trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) }
}

extension String {
    func removeWhitespaceRuns() -> String {
        var lastWasSpace = false
        
        let chars = compactMap { c -> Character? in
            if c.isWhitespace {
                if !lastWasSpace {
                    lastWasSpace = true
                    return " "
                } else {
                    return nil
                }
            } else {
                lastWasSpace = false
                return c
            }
        }
        return String(chars)
    }
}

extension String {
    func limited(to count: Int?) -> String {
        guard let count = count else { return self }
        return String(prefix(count))
    }
}

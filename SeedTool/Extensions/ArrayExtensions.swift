//
//  ArrayExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

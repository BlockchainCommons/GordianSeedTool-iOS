//
//  StringTransformable.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/11/20.
//

import Foundation

protocol StringTransformable {
    static func values(from string: String) -> [Self]?
    static func string(from values: [Self]) -> String
}

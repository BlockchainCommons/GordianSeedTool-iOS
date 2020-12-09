//
//  ValueViewable.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

protocol ValueViewable {
    static var minimumWidth: CGFloat { get }
    var view: AnyView { get }
}

protocol StringTransformable {
    static func values(from string: String) -> [Self]?
    static func string(from values: [Self]) -> String
}

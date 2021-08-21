//
//  TokenViewable.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

protocol TokenViewable {
    static var minimumWidth: CGFloat { get }
    var view: AnyView { get }
}

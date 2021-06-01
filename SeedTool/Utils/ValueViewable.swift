//
//  ValueViewable.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

protocol ValueViewable {
    static var minimumWidth: CGFloat { get }
    var view: AnyView { get }
}

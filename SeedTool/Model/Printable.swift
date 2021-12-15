//
//  Printable.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 4/8/21.
//

import SwiftUI

protocol Printable {
    associatedtype Page: View
    
    var name: String { get }
    func printPages(model: Model) -> [Page]
}

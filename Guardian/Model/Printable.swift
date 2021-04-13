//
//  Printable.swift
//  Guardian
//
//  Created by Wolf McNally on 4/8/21.
//

import SwiftUI

protocol Printable {
    associatedtype Page: View
    
    var name: String { get }
    var pages: [Page] { get }
}

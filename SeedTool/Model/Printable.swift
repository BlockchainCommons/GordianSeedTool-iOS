//
//  Printable.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 4/8/21.
//

import SwiftUI

protocol Printable: Equatable {
    associatedtype Page: View
    
    var name: String { get }
    func printPages(model: Model) -> [Page]
}

struct PrintablePages: Printable {
    let id = UUID()
    let name: String
    let printables: [AnyPrintable]
    
    func printPages(model: Model) -> [AnyView] {
        var views: [AnyView] = []
        
        for p in printables {
            views.append(contentsOf: p.printPages(model: model))
        }
        
        return views
    }
    
    static func ==(lhs: PrintablePages, rhs: PrintablePages) -> Bool {
        lhs.id == rhs.id
    }
}

struct AnyPrintable: Printable {
    static func == (lhs: AnyPrintable, rhs: AnyPrintable) -> Bool {
        lhs.id == rhs.id
    }
    
    typealias Page = AnyView
    private let _name: () -> String
    let _printPages: (_ model: Model) -> [AnyView]
    let id = UUID()

    init<P: Printable>(_ p: P) {
        self._name = {
            p.name
        }

        self._printPages = {
            p.printPages(model: $0).map { $0.eraseToAnyView() }
        }
    }

    var name: String {
        _name()
    }

    func printPages(model: Model) -> [AnyView] {
        _printPages(model)
    }
}

extension Printable {
    func eraseToAnyPrintable() -> AnyPrintable {
        AnyPrintable(self)
    }
}

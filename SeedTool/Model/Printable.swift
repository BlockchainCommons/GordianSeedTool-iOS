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
    var printExportFields: ExportFields { get }
    var printPages: [Page] { get }
    var jobName: String { get }
}

extension Printable {
    var jobName: String {
        Export(name: name, fields: printExportFields).filename
    }
}

struct PrintablePages: Printable {
    let id = UUID()
    let name: String
    let printExportFields: ExportFields
    let printables: [AnyPrintable]
    
    var printPages: [AnyView] {
        var views: [AnyView] = []
        
        for p in printables {
            views.append(contentsOf: p.printPages)
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
    private let _printExportFields: () -> ExportFields
    let _printPages: () -> [AnyView]
    let id = UUID()

    init<P: Printable>(_ p: P) {
        self._name = {
            p.name
        }

        self._printExportFields = {
            p.printExportFields
        }

        self._printPages = {
            p.printPages.map { $0.eraseToAnyView() }
        }
    }

    var name: String {
        _name()
    }
    
    var printExportFields: ExportFields {
        _printExportFields()
    }

    var printPages: [AnyView] {
        _printPages()
    }
}

extension Printable {
    func eraseToAnyPrintable() -> AnyPrintable {
        AnyPrintable(self)
    }
}

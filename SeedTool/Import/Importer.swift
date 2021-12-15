//
//  Importer.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/22/20.
//

import SwiftUI

protocol Importer: View {
    associatedtype ModelType: ImportModel

    init(model: ModelType, seed: Binding<ModelSeed?>, shouldScan: Bool)
}

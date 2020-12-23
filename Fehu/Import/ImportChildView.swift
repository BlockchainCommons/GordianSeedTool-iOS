//
//  ImportChildView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/22/20.
//

import SwiftUI

protocol ImportChildView: View {
    associatedtype ModelType: ImportModel
    
    init(modelType: ModelType.Type, seed: Binding<Seed?>)
}

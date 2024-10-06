//
//  ImportModel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/23/20.
//

import Combine
import BCApp
import Foundation

@MainActor
class ImportModel: ObservableObject {
    @Published var text: String = ""
    @Published var isValid: Bool = false
    let guidancePublisher: PassthroughSubject<AttributedString?, Never> = .init()
    let seedPublisher: PassthroughSubject<ModelSeed?, Never> = .init()
    var validator: ValidationPublisher! = nil
    
    required init() {
    }
    
    lazy var fieldValidator: AnyPublisher<String, Never> = {
        $text
            .debounceField()
            .trimWhitespace()
    }()
    
    var name: String { "NONE" }
    var typeName: String { "NONE" }
}

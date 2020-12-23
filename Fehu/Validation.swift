//
//  Validation.swift
//  Fehu
//
//  Created by Wolf McNally on 12/20/20.
//

import Foundation
import SwiftUI
import Combine

enum Validation {
    case valid
    case invalid(String?)
}

typealias ValidationPublisher = AnyPublisher<Validation, Never>

extension Publisher {
    func debounceField() -> Publishers.Debounce<Self, RunLoop> {
        debounce(for: .seconds(0.5), scheduler: RunLoop.main)
    }
}

extension Publisher {
    func validateAlways() -> ValidationPublisher where Failure == Never {
        map { _ in Validation.valid }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == String, Failure == Never {
    func trimWhitespace() -> AnyPublisher<String, Never> {
        map { string in
            string.trim()
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output : Collection {
    func isEmpty() -> Publishers.Map<Self, Bool> {
        map { collection in
            collection.isEmpty
        }
    }

    func validateNotEmpty(_ message: String? = nil) -> ValidationPublisher where Failure == Never {
        isEmpty().map {
            $0 ? .invalid(message) : .valid
        }
        .eraseToAnyPublisher()
    }
}

struct ValidationModifier: ViewModifier {
    @State var latestValidation: Validation = .valid
    let validationPublisher: ValidationPublisher

    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
            validationMessage
        }.onReceive(validationPublisher) { validation in
            withAnimation {
                self.latestValidation = validation
            }
        }
    }

    var validationMessage: some View {
        switch latestValidation {
        case .valid:
            return AnyView(EmptyView())
        case .invalid(let message):
            let message = message ?? "Invalid."
            let text = Text(message)
                .foregroundColor(Color.red)
                .font(.caption)
            return AnyView(text)
        }
    }
}

extension View {
    func validation(_ validationPublisher: ValidationPublisher) -> some View {
        modifier(ValidationModifier(validationPublisher: validationPublisher))
    }
}

//
//  ImportSSKRModel.swift
//  Fehu
//
//  Created by Wolf McNally on 12/23/20.
//

import Combine

final class ImportSSKRModel: ImportModel {
    required init() {
        super.init()
        validator = fieldValidator
            .validateSSKR(seedPublisher: seedPublisher)
    }

    override var typeName: String { "SSKR words" }
}

extension Publisher where Output == String, Failure == Never {
    func validateSSKR(seedPublisher: PassthroughSubject<Seed?, Never>) -> ValidationPublisher {
        map { string in
            do {
                let seed = try Seed(sskr: string)
                seedPublisher.send(seed)
                return .valid
            } catch {
                seedPublisher.send(nil)
                return .invalid(error.localizedDescription)
            }
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}

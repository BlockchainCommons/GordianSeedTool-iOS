//
//  ImportBIP39Model.swift
//  Fehu
//
//  Created by Wolf McNally on 12/23/20.
//

import Combine

final class ImportBIP39Model: ImportModel {
    required init() {
        super.init()
        validator = fieldValidator
            .validateBIP39(seedPublisher: seedPublisher)
    }
}

extension Publisher where Output == String, Failure == Never {
    func validateBIP39(seedPublisher: PassthroughSubject<Seed?, Never>) -> ValidationPublisher {
        map { string in
            do {
                let seed = try Seed(bip39: string)
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

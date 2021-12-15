//
//  ImportBIP39Model.swift
//  Gordian Seed Tool
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

    override var name: String { "BIP39" }
    override var typeName: String { "BIP39 words" }
}

extension Publisher where Output == String, Failure == Never {
    func validateBIP39(seedPublisher: PassthroughSubject<ModelSeed?, Never>) -> ValidationPublisher {
        map { string in
            do {
                let seed = try ModelSeed(mnemonic: string)
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

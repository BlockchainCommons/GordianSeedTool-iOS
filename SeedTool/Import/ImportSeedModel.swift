//
//  ImportSeedModel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/19/20.
//

import Combine
import BCApp

final class ImportSeedModel: ImportModel {
    required init() {
        super.init()
        validator = fieldValidator
            .validateSeedUR(seedPublisher: seedPublisher)
    }

    override var name: String { "UR" }
    override var typeName: String { "ur:crypto-seed" }
}

extension Publisher where Output == String, Failure == Never {
    func validateSeedUR(seedPublisher: PassthroughSubject<ModelSeed?, Never>) -> ValidationPublisher {
        map { string in
            do {
                let seed = try ModelSeed(urString: string)
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

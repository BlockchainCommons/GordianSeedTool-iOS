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

    override var name: String { "Seed" }
    override var typeName: String { "`ur:envelope` or `ur:seed`" }
}

extension Publisher where Output == String, Failure == Never {
    func validateSeedUR(seedPublisher: PassthroughSubject<ModelSeed?, Never>) -> ValidationPublisher {
        map { string in
            do {
                if let envelope = try? Envelope(urString: string) {
                    if let seed = try? ModelSeed(envelope: envelope) {
                        seedPublisher.send(seed)
                        return .valid
                    } else {
                        throw GeneralError("Envelope does not contain a seed.")
                    }
                } else {
                    if let seed = try? ModelSeed(urString: string) {
                        seedPublisher.send(seed)
                        return .valid
                    } else {
                        throw GeneralError("Not a `ur:envelope` or a `ur:seed`.")
                    }
                }
            } catch {
                seedPublisher.send(nil)
                return .invalid(error.localizedDescription)
            }
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}

//
//  ImportURModel.swift
//  Fehu
//
//  Created by Wolf McNally on 12/19/20.
//

import Combine

final class ImportURModel: ImportModel {
    required init() {
        super.init()
        validator = fieldValidator
            .validateUR(seedPublisher: seedPublisher)
    }

    override var name: String { "UR" }
    override var typeName: String { "ur:crypto-seed" }
}

extension Publisher where Output == String, Failure == Never {
    func validateUR(seedPublisher: PassthroughSubject<Seed?, Never>) -> ValidationPublisher {
        map { string in
            do {
                let seed = try Seed(urString: string)
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

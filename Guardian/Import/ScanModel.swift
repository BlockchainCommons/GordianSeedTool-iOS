//
//  ScanModel.swift
//  Guardian
//
//  Created by Wolf McNally on 2/18/21.
//

import Combine
import URKit

enum ScanResult {
    case seed(Seed)
    case request(TransactionRequest)
}

final class ScanModel: ObservableObject {
    @Published var text: String = ""
    @Published var isValid: Bool = false
    let resultPublisher: PassthroughSubject<ScanResult?, Never> = .init()
    var validator: ValidationPublisher! = nil

    init() {
        validator = fieldValidator
            .validateScanResult(resultPublisher: resultPublisher)
    }

    lazy var fieldValidator: AnyPublisher<String, Never> = {
        $text
            .debounceField()
            .trimWhitespace()
    }()
}

extension Publisher where Output == String, Failure == Never {
    func validateScanResult(resultPublisher: PassthroughSubject<ScanResult?, Never>) -> ValidationPublisher {
        func validateUR(string: String) -> Validation {
            do {
                let ur = try URDecoder.decode(string)
                switch ur.type {
                case "crypto-seed":
                    let seed = try Seed(ur: ur)
                    resultPublisher.send(.seed(seed))
                case "crypto-request":
                    let request = try TransactionRequest(ur: ur)
                    resultPublisher.send(.request(request))
                default:
                    return .invalid("Unrecognized UR.")
                }
                return .valid
            } catch {
                resultPublisher.send(nil)
                return .invalid(error.localizedDescription)
            }
        }
        
        return map { string -> Validation in
            return validateUR(string: string)
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}

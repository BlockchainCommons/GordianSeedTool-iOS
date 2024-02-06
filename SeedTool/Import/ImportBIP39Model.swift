//
//  ImportBIP39Model.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/23/20.
//

import Combine
import BCApp
import Foundation
import UIKit
import SwiftUI

final class ImportBIP39Model: ImportModel {
    required init() {
        super.init()
        validator = fieldValidator
            .convertNonwordToSpace()
            .removeWhitespaceRuns()
            .trimWhitespace()
            .validateBIP39(seedPublisher: seedPublisher, guidancePublisher: guidancePublisher)
    }

    override var name: String { "BIP39" }
    override var typeName: String { "BIP39 words" }
}

extension Publisher where Output == String, Failure == Never {
    func validateBIP39(seedPublisher: PassthroughSubject<ModelSeed?, Never>, guidancePublisher: PassthroughSubject<AttributedString?, Never>) -> ValidationPublisher {
        map { string in
            let guidance = BIP39Guidance(string)
            if let guidanceString = guidance.guidanceString {
                guidancePublisher.send(guidanceString)
            }
            switch guidance.result {
            case .success(let seed):
                seedPublisher.send(seed)
                return .valid
            case .failure(let error):
                seedPublisher.send(nil)
                return .invalid(error.localizedDescription)
            }
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}

class BIP39Guidance: Guidance {
    static let validWords = Wally.bip39AllWords()
    static let initialLetters = 4
    static var firstAndLastLettersMatch = false
    let wordGuidances: [WordGuidance]
    private(set) var summary: AttributedString? = nil
    private(set) var result: Result<ModelSeed, Error> = .failure(.invalid)
    private(set) var guidanceString: AttributedString? = nil
    
    enum Error: LocalizedError {
        case invalid
    }

    init(_ string: String) {
        self.wordGuidances = Self.makeWordGuidances(string)
        makeSummary()
        self.guidanceString = makeGuidanceString
    }
    
    func makeSummary() {
        guard !wordGuidances.isEmpty else {
            return
        }
        
        if allValid {
            guard [12, 15, 18, 21, 24].contains(wordGuidances.count) else {
                summary = AttributedString(warning: "BIP-39 sequences must be of length 12, 15, 18, 21, or 24. Currently: \(wordGuidances.count).")
                return
            }

            do {
                result = .success(try ModelSeed(mnemonic: makeUpdatedString))
            } catch {
                summary = AttributedString(error: "Not a valid BIP-39 word sequence.")
            }
        } else if anyInvalid {
            summary = AttributedString(error: "Some entered words cannot be valid BIP-39 words.")
        } else {
            summary = AttributedString(warning: "Some entered words might match more than one BIP-39 word.")
        }
    }
}

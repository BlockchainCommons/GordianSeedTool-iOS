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
            let (updatedString, guidance) = makeGuidance(string)
            guidancePublisher.send(guidance)
            do {
                let seed = try ModelSeed(mnemonic: updatedString)
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
    
    private func makeGuidance(_ string: String) -> (String, AttributedString) {
        let guidance = BIP39Guidance(string)
        return (guidance.updatedString, guidance.guidanceString)
    }
}

class BIP39Guidance: Guidance {
    static let validWords = Wally.bip39AllWords()
    static let initialLetters = 4
    static var firstAndLastLettersMatch = false
    let wordGuidances: [WordGuidance]
    
    init(_ string: String) {
        self.wordGuidances = Self.makeWordGuidances(string)
    }
}

//
//  ImportByteWordsModel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/4/21.
//

import Combine
import BCApp
import Foundation

final class ImportByteWordsModel: ImportModel {
    required init() {
        super.init()
        validator = fieldValidator
            .convertNonwordToSpace()
            .removeWhitespaceRuns()
            .trimWhitespace()
            .validateByteWords(seedPublisher: seedPublisher, guidancePublisher: guidancePublisher)
    }

    override var name: String { "ByteWords" }
    override var typeName: String { "ByteWords" }
}

extension Publisher where Output == String, Failure == Never {
    func validateByteWords(seedPublisher: PassthroughSubject<ModelSeed?, Never>, guidancePublisher: PassthroughSubject<AttributedString?, Never>) -> ValidationPublisher {
        map { string in
            let (updatedString, guidance) = makeGuidance(string)
            guidancePublisher.send(guidance)
            do {
                let seed = try ModelSeed(byteWords: updatedString)
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
        let guidance = BytewordsGuidance(string)
        return (guidance.updatedString, guidance.guidanceString)
    }
}

class BytewordsGuidance: Guidance {
    static let validWords = Bytewords.allWords
    static let initialLetters = 3
    static let firstAndLastLettersMatch = true
    let wordGuidances: [WordGuidance]
    
    init(_ string: String) {
        self.wordGuidances = Self.makeWordGuidances(string)
    }
}

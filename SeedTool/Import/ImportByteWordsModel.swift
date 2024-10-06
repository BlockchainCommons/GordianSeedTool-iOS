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
    @MainActor
    func validateByteWords(seedPublisher: PassthroughSubject<ModelSeed?, Never>, guidancePublisher: PassthroughSubject<AttributedString?, Never>) -> ValidationPublisher {
        map { string in
            let guidance = BytewordsGuidance(string)
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

class BytewordsGuidance: Guidance {
    static let validWords = Bytewords.allWords
    static let initialLetters = 3
    static let firstAndLastLettersMatch = true
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
            guard wordGuidances.count >= 20 else {
                summary = AttributedString(warning: "You need to enter at least 20 Bytewords. Currently: \(wordGuidances.count).")
                return
            }

            do {
                result = .success(try ModelSeed(byteWords: makeUpdatedString))
            } catch {
                if
                    let e = error as? BytewordsDecodingError,
                    e == .invalidChecksum
                {
                    summary = AttributedString(error: "Valid Bytewords, but the checksum doesn’t match.")
                } else {
                    summary = AttributedString(error: "Something's wrong!")
                }
            }
        } else if anyInvalid {
            summary = AttributedString(error: "Some entered words cannot be valid Bytewords.")
        } else {
            summary = AttributedString(warning: "Some entered words might match more than one Byteword.")
        }
    }
}

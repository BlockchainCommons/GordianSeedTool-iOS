import Foundation

struct WordGuidance {
    let input: String
    let matches: [String]
    
    init(input: String, validWords: [String], initialLetters: Int, firstAndLastLettersMatch: Bool) {
        self.input = input.lowercased()
        self.matches = Self.matches(input: self.input, validWords: validWords, initialLetters: initialLetters, firstAndLastLettersMatch: firstAndLastLettersMatch)
    }
    
    private static func matches(input: String, validWords: [String], initialLetters: Int, firstAndLastLettersMatch: Bool) -> [String] {
        guard let regex = try? Regex(".*" + input.map { "\($0).*" }.joined()) else {
            return []
        }
        var result: [String] = []
        for validWord in validWords {
            if validWord == input {
                return [validWord]
            } else if firstAndLastLettersMatch,
                      input.count == 2,
                      input.first! == validWord.first!,
                      input.last! == validWord.last!
            {
                return [validWord]
            } else if input.count == initialLetters,
                      validWord.count >= initialLetters,
                      validWord.prefix(count: initialLetters) == input
            {
                return [validWord]
            }
            if validWord.contains(regex) {
                result.append(validWord)
            }
        }
        return result
    }
    
    enum Validation {
        case valid
        case noMatches
        case multipleMatches
    }
    
    var validation: Validation {
        switch matches.count {
        case 1:
            return .valid
        case 0:
            return .noMatches
        default:
            if matches.first! == input {
                return .valid
            } else {
                return .multipleMatches
            }
        }
    }
    
    var bestMatch: String {
        if matches.count == 1 {
            return matches.first!
        } else {
            return input
        }
    }
    
    var attributedDescription: AttributedString {
        switch validation {
        case .valid:
            return AttributedString("\(bestMatch)", color: .green, bold: true)
        case .multipleMatches:
            let a = AttributedString(input, color: .yellowLightSafe)
            let b = AttributedString("\(matches.count)", color: .yellowLightSafe, smallStyle: true)
            return a + b
        case .noMatches:
            return AttributedString("❌\(input)", color: .red)
        }
    }
}

extension WordGuidance: CustomStringConvertible {
    var description: String {
        switch validation {
        case .valid:
            "✅\(matches.first!)"
        case .multipleMatches:
            "⚠️\(input)-\(matches.count)"
        case .noMatches:
            "❌\(input)"
        }
    }
}

protocol Guidance: CustomStringConvertible {
    static var validWords: [String] { get }
    static var initialLetters: Int { get }
    static var firstAndLastLettersMatch: Bool { get }
    var wordGuidances: [WordGuidance] { get }
}

extension Guidance {
    static func makeWordGuidances(_ string: String) -> [WordGuidance] {
        let words = string.split(separator: " ").map(String.init)
        return words.map { WordGuidance(input: $0, validWords: validWords, initialLetters: initialLetters, firstAndLastLettersMatch: firstAndLastLettersMatch)}
    }

    var description: String {
        wordGuidances
            .map { $0.description }
            .joined(separator: " ")
    }
    
    var updatedString: String {
        return wordGuidances
            .map { $0.bestMatch }
            .joined(separator: " ")
    }
    
    var guidanceString: AttributedString {
        wordGuidances
            .map { $0.attributedDescription }
            .joined(separator: " ")
    }
}

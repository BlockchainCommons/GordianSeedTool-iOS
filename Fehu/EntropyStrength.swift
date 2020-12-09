//
//  EntropyStrength.swift
//  Fehu
//
//  Created by Wolf McNally on 12/8/20.
//

import Foundation
import SwiftUI

enum EntropyStrength: CustomStringConvertible {
    case veryWeak
    case weak
    case moderate
    case strong
    case veryStrong

    // https://keepass.info/help/kb/pw_quality_est.html
    static func categorize(_ e: Double) -> Self {
        switch e {
        case ..<64:
            return .veryWeak
        case ..<80:
            return .weak
        case ..<112:
            return .moderate
        case ..<128:
            return .strong
        default:
            return .veryStrong
        }
    }

    var description: String {
        switch self {
        case .veryWeak:
            return "Very Weak"
        case .weak:
            return "Weak"
        case .moderate:
            return "Moderate"
        case .strong:
            return "Strong"
        case .veryStrong:
            return "Very Strong"
        }
    }

    var color: Color {
        switch self {
        case .veryWeak:
            return .red
        case .weak:
            return .orange
        case .moderate:
            return .yellow
        case .strong:
            return .green
        case .veryStrong:
            return .blue
        }
    }
}

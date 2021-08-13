//
//  SSKRPreset.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/18/21.
//

import Foundation
import SwiftUI

enum SSKRPreset: Int, Segment, CaseIterable {
    case oneOfOne
    case twoOfThree
    case threeOfFive
    case fourOfNine
    case twoOfThreeOfTwoOfThree
    case custom

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .oneOfOne:
            return "1 of 1"
        case .twoOfThree:
            return "2 of 3"
        case .threeOfFive:
            return "3 of 5"
        case .fourOfNine:
            return "4 of 9"
        case .twoOfThreeOfTwoOfThree:
            return "2 of 3 shares, of two of three groups"
        case .custom:
            return "Custom"
        }
    }

    var subtitle: String? {
        switch self {
        case .oneOfOne:
            return "A simple list of words for easy backup."
        case .twoOfThree:
            return "Three shares, two needed to recover."
        case .threeOfFive:
            return "Five shares, three needed to recover."
        case .fourOfNine:
            return "Nine shares, four needed to recover."
        case .twoOfThreeOfTwoOfThree:
//            return "Foo"
            return "Three groups of three shares each, nine shares total. Four shares, two from any two of the groups needed to recover."
        case .custom:
            return "Anything you like, just adjust the controls below."
        }
    }

    static func value(for model: SSKRModel) -> Self {
        if model == modelOneOfOne {
            return .oneOfOne
        } else if model == modelTwoOfThree {
            return .twoOfThree
        } else if model == modelThreeOfFive {
            return .threeOfFive
        } else if model == modelFourOfNine {
            return .fourOfNine
        } else if model == modelTwoOfThreeOfTwoOfThree {
            return .twoOfThreeOfTwoOfThree
        } else {
            return .custom
        }
    }

    var model: SSKRModel? {
        switch self {
        case .oneOfOne:
            return Self.modelOneOfOne
        case .twoOfThree:
            return Self.modelTwoOfThree
        case .threeOfFive:
            return Self.modelThreeOfFive
        case .fourOfNine:
            return Self.modelFourOfNine
        case .twoOfThreeOfTwoOfThree:
            return Self.modelTwoOfThreeOfTwoOfThree
        case .custom:
            return nil
        }
    }
    
    var label: AnyView {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
                .font(.body)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
            }
        }
        .fixedVertical()
//        .debugRed()
        .eraseToAnyView()
    }

    static let modelOneOfOne = SSKRModel(preset: .oneOfOne)
    static let modelTwoOfThree = SSKRModel(1, [(2, 3)], .twoOfThree)
    static let modelThreeOfFive = SSKRModel(1, [(3, 5)], .threeOfFive)
    static let modelFourOfNine = SSKRModel(1, [(4, 9)], .fourOfNine)
    static let modelTwoOfThreeOfTwoOfThree = SSKRModel(2, [(2, 3), (2, 3), (2, 3)], .twoOfThreeOfTwoOfThree )
}

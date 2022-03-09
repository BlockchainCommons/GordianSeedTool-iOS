//
//  LifeHashNameGenerator.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/20/20.
//

import Foundation
import LifeHash
import WolfLorem
import BCFoundation

final class LifeHashNameGenerator: ObservableObject {
    @Published var suggestedName: String?
    private var colorName: String = "none"

    init(lifeHashState: LifeHashState?) {
        guard let lifeHashState = lifeHashState else { return }

        lifeHashState.$osImage
            .receive(on: DispatchQueue.global())
            .map { uiImage in
                guard let uiImage = uiImage else { return "Untitled" }
                return self.update(image: uiImage)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$suggestedName)
        
        if let image = lifeHashState.osImage {
            suggestedName = update(image: image)
        }
    }
    
    func update(image: OSImage) -> String {
        if let matchedColors = getMatchedColors(for: image, quality: .highest) {
            self.colorName = matchedColors.background.namedColor.name
        } else {
            self.colorName = NamedColor.colors.randomElement()!.name
        }
        return self.next()
    }

    func next() -> String {
        let words = Lorem.bytewords(2)
        return [colorName, words].joined(separator: " ").capitalized
    }
}

extension Lorem {
    static func bytewords(_ count: Int) -> String {
        (0..<count)
            .map( { _ in Bytewords.allWords.randomElement()! } )
            .joined(separator: " ")
    }
}

//
//  Images.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/27/22.
//

import SwiftUI
import UIKit

extension Image {
    // Seed Generation
    static var quickCreate: Image { Image(systemName: "hare") }
    static var coinFlips: Image { Image(systemName: "centsign.circle") }
    static var dieRolls: Image { Image(systemName: "die.face.3") }
    static var playingCards: Image { Image(systemName: "suit.heart") }
    
    static func dieFace(_ value: Int) -> Image {
        Image(systemName: "die.face.\(value).fill")
    }
    
    static func cardSuit(_ suit: Card.Suit) -> Image {
        Image(systemName: suit.imageName)
    }
}

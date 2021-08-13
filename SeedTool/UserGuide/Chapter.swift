//
//  Chapter.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/27/21.
//

import SwiftUI
import MarkdownUI

enum Chapter: CaseIterable, Identifiable {
    case aboutSeedTool
    case whatIsASeed
    case whatIsALifehash
    case whatIsAUR
    case whatAreBytewords
    case whatIsBIP39
    case whatIsSSKR
    case whatIsKeyDerivation
    case whatIsACosigner
    case licenseAndDisclaimer
    
    static var chapterTitles: [String: String] = [:]
    
    var id: String {
        name
    }
    
    var name: String {
        switch self {
        case .aboutSeedTool:
            return "about-seed-tool"
        case .whatIsASeed:
            return "what-is-a-seed"
        case .whatIsALifehash:
            return "what-is-a-lifehash"
        case .whatIsAUR:
            return "what-is-a-ur"
        case .whatAreBytewords:
            return "what-are-bytewords"
        case .whatIsBIP39:
            return "what-is-bip-39"
        case .whatIsSSKR:
            return "what-is-sskr"
        case .whatIsKeyDerivation:
            return "what-is-key-derivation"
        case .whatIsACosigner:
            return "what-is-a-cosigner"
        case .licenseAndDisclaimer:
            return "license-and-disclaimer"
        }
    }
    
    var header: AnyView? {
        switch self {
        case .aboutSeedTool:
            return IconHeader(image: Image("seed.circle")).eraseToAnyView()
        case .whatIsASeed:
            return IconHeader(image: Image("seed.circle")).eraseToAnyView()
        case .whatIsALifehash:
            return LifeHashHeader().eraseToAnyView()
        case .whatIsAUR:
            return URHeader().eraseToAnyView()
        case .whatAreBytewords:
            return ByteWordsHeader().eraseToAnyView()
        case .whatIsBIP39:
            return BIP39Header().eraseToAnyView()
        case .whatIsSSKR:
            return IconHeader(image: Image("sskr.bar")).eraseToAnyView()
        case .whatIsKeyDerivation:
            return IconHeader(image: Image("key.fill.circle")).eraseToAnyView()
        case .whatIsACosigner:
            return IconHeader(image: Image("bc-logo")).eraseToAnyView()
        case .licenseAndDisclaimer:
            return nil
        }
    }
    
    var shortTitle: String? {
        switch self {
        case .whatIsASeed:
            return "Seed?"
        case .whatIsALifehash:
            return "Lifehash?"
        case .whatIsAUR:
            return "UR?"
        case .whatAreBytewords:
            return "Bytewords?"
        case .whatIsBIP39:
            return "BIP-39?"
        case .whatIsSSKR:
            return "SSKR?"
        case .whatIsACosigner:
            return "Cosigner?"
        default:
            return nil
        }
    }
    
    var markdownChapter: MarkdownChapter {
        MarkdownChapter(name: name)
    }
    
    var title: String {
        if Self.chapterTitles[name] == nil {
            Self.chapterTitles[name] = markdownChapter.title ?? "Untitled"
        }
        return Self.chapterTitles[name]!
    }
    
    var markdown: Markdown {
        Markdown(Document(markdownChapter.body))
    }
}

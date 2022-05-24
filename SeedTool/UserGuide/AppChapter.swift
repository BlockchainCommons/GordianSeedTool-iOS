import SwiftUI
import MarkdownUI
import BCApp

enum AppChapter: CaseIterable, Identifiable, ChapterProtocol {
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
    
    static var appLogo: AnyView {
        AppLogo().eraseToAnyView()
    }
    
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
            return IconChapterHeader(image: Image.seed).eraseToAnyView()
        case .whatIsASeed:
            return IconChapterHeader(image: Image.seed).eraseToAnyView()
        case .whatIsALifehash:
            return LifeHashHeader().eraseToAnyView()
        case .whatIsAUR:
            return URHeader().eraseToAnyView()
        case .whatAreBytewords:
            return ByteWordsHeader().eraseToAnyView()
        case .whatIsBIP39:
            return BIP39Header().eraseToAnyView()
        case .whatIsSSKR:
            return IconChapterHeader(image: Image.sskr).eraseToAnyView()
        case .whatIsKeyDerivation:
            return IconChapterHeader(image: Image.key).eraseToAnyView()
        case .whatIsACosigner:
            return IconChapterHeader(image: Image.bcLogo).eraseToAnyView()
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
        case .whatIsKeyDerivation:
            return "Derivation?"
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

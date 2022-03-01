//
//  Images.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/27/22.
//

import SwiftUI
import UIKit

extension UIImage {
    static var copy: UIImage { UIImage(systemName: "doc.on.doc")! }
}

extension Image {
    static var bcLogo: Image { Image("bc-logo") }
    
    // Formats
    static var ur: Image { Image("ur.bar") }
    static var base58: Image { Image("58.bar") }
    static var sskr: Image { Image("sskr.bar") }
    static var bip39: Image { Image("39.bar") }
    static var byteWords: Image { Image("bytewords.bar") }
    static var hex: Image { Image("hex.bar") }
    static var secure: Image { Image(systemName: "shield.lefthalf.fill") }
    
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
    
    // Actions
    static var add: Image { Image(systemName: "plus") }
    static var export: Image { Image(systemName: "square.and.arrow.up.on.square") }
    static var share: Image { Image(systemName: "square.and.arrow.up") }
    static var copy: Image { Image(systemName: "doc.on.doc") }
    static var confirmCopy: Image { Image(systemName: "doc.on.doc.fill") }
    static var paste: Image { Image(systemName: "doc.on.clipboard") }
    static var clear: Image { Image(systemName: "clear") }
    static var clearField: Image { Image(systemName: "multiply.circle.fill") }
    static var deletePrevious: Image { Image(systemName: "delete.left") }
    static var menu: Image { Image(systemName: "ellipsis.circle") }
    static var randomize: Image { Image(systemName: "die.face.5.fill") }
    static var backup: Image { Image(systemName: "archivebox") }
    static var scan: Image { Image(systemName: "qrcode.viewfinder") }
    static var displayQRCode: Image { Image(systemName: "qrcode" ) }
    static var print: Image { Image(systemName: "printer") }
    static var files: Image { Image(systemName: "doc") }
    static var photos: Image { Image(systemName: "photo") }
    static var nfc: Image { Image("nfc") }
    static var settings: Image { Image(systemName: "gearshape") }
    static var developer: Image { Image(systemName: "ladybug.fill") }
    static var guide: Image { Image(systemName: "info.circle") }
    
    static var camera: Image { Image(systemName: "camera.circle")}
    static var frontCamera: Image { Image(systemName: "arrow.triangle.2.circlepath.circle.fill")}
    static var backCamera: Image { Image(systemName: "arrow.triangle.2.circlepath.circle")}
    
    static func iCloud(on: Bool) -> Image {
        Image(systemName: on ? "icloud" : "xmark.icloud")
    }
    
    static var info: Image { Image(systemName: "info.circle.fill") }
    static var warning: Image { Image(systemName: "exclamationmark.triangle.fill") }
    static var success: Image { Image(systemName: "checkmark.circle.fill") }
    static var failure: Image { Image(systemName: "xmark.octagon.fill") }

    static func operation(success: Bool) -> Image {
        success ? self.success : self.failure
    }
    
    static var reveal: Image { Image(systemName: "eye") }
    static var hide: Image { Image(systemName: "eye.slash") }
    
    static func toggleVisibility(isRevealed: Bool) -> Image {
        isRevealed ? hide : reveal
    }

    static var locked: Image { Image(systemName: "lock.fill") }
    static var unlocked: Image { Image(systemName: "lock.open.fill") }
    
    static func toggleUnlocked(isRevealed: Bool) -> Image {
        isRevealed ? unlocked : locked
    }
    
    enum Direction {
        case previous
        case next
    }
    
    static func navigation(_ direction: Direction) -> Image {
        switch direction {
        case .previous:
            return Image(systemName: "arrowtriangle.left.fill")
        case .next:
            return Image(systemName: "arrowtriangle.right.fill")
        }
    }

    // Objects
    static var seed: Image { Image("seed.circle") }
    static var key: Image { Image("key.fill.circle") }
    static var privateKey: Image { Image("key.prv.circle") }
    static var publicKey: Image { Image("key.pub.circle") }
    static var address: Image { Image(systemName: "envelope.circle") }
    static var outputDescriptor: Image { Image(systemName: "rhombus") }
    static var outputBundle: Image { Image(systemName: "square.stack.3d.up") }
    static var missing: Image { Image(systemName: "questionmark.circle") }

    // Fields
    static var name: Image { Image(systemName: "quote.bubble") }
    static var date: Image { Image(systemName: "calendar") }
    static var note: Image { Image(systemName: "note.text") }

    // Assets
    static var bitcoin: Image { Image("asset.btc") }
    static var ethereum: Image { Image("asset.eth") }
    static var bitcoinCash: Image { Image("asset.bch") }
    static var ethereumClassic: Image { Image("asset.etc") }
    static var litecoin: Image { Image("asset.ltc") }
    
    // Networks
    static var mainnet: Image { Image("network.main") }
    static var testnet: Image { Image("network.test") }
    static var segwit: Image { Image("segwit") }
    
    // UI
    static var flowDown: Image { Image(systemName: "arrowtriangle.down.fill") }
    
    // Transactions
    static var txSent: Image { Image(systemName: "arrow.right") }
    static var txChange: Image { Image(systemName: "arrow.uturn.left") }
    static var txInput: Image { Image(systemName: "arrow.down") }
    static var txFee: Image { Image(systemName: "lock.circle") }
    static var signature: Image { Image(systemName: "signature") }
    static var signatureNeeded: Image { Image(systemName: "ellipsis.circle") }
    
    // Misc
    static func circled(_ s: String) -> Image { Image(systemName: "\(s).circle") }
}

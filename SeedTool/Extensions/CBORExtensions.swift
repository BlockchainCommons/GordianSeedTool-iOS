//
//  CBORExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/17/21.
//

import URKit

extension CBOR.Tag {
    static let seed = CBOR.Tag(300)
    static let hdKey = CBOR.Tag(303)
    static let derivationPath = CBOR.Tag(304)
    static let useInfo = CBOR.Tag(305)
    static let sskrShare = CBOR.Tag(309)
    static let transactionRequest = CBOR.Tag(312)
    static let transactionResponse = CBOR.Tag(313)
    
    static let seedRequestBody = CBOR.Tag(500)
    static let keyRequestBody = CBOR.Tag(501)
    static let psbtSignatureRequestBody = CBOR.Tag(502)
}

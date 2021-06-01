//
//  ScanModel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/18/21.
//

import Combine
import URKit
import SSKR

enum ScanResult {
    case seed(Seed)
    case request(TransactionRequest)
    case failure(Error)
}

final class ScanModel: ObservableObject {
    let resultPublisher = PassthroughSubject<ScanResult, Never>()
    var sskrDecoder: SSKRDecoder
    
    init(sskrDecoder: SSKRDecoder) {
        self.sskrDecoder = sskrDecoder
    }
    
    func receive(urString: String) {
        do {
            try receive(ur: UR(urString: urString))
        } catch {
            resultPublisher.send(.failure(GeneralError("Unrecognized format.")))
        }
    }
    
    func receive(ur: UR) {
        do {
            switch ur.type {
            case "crypto-seed":
                let seed = try Seed(ur: ur)
                resultPublisher.send(.seed(seed))
            case "crypto-request":
                let request = try TransactionRequest(ur: ur)
                resultPublisher.send(.request(request))
            case "crypto-sskr":
                if let seed = try sskrDecoder.addShare(ur: ur) {
                    resultPublisher.send(.seed(seed))
                }
            default:
                let message = "Unrecognized UR: \(ur.type)"
                resultPublisher.send(.failure(GeneralError(message)))
            }
        } catch {
            resultPublisher.send(.failure(error))
        }
    }
}

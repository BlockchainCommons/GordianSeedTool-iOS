//import Foundation
//import CryptoTokenKit
//import WolfBase
//import PCSC
//
//func testNFC() {
//    Task {
//        print("testNFC")
//        let slotManager = TKSmartCardSlotManager.default!
//        
//        var slots: [TKSmartCardSlot] = []
//        for slotName in slotManager.slotNames {
//            print("slotName: \(slotName)")
//            if let slot = await slotManager.getSlot(withName: slotName) {
//                print("slot: \(slot)")
//                slots.append(slot)
//            }
//        }
//        
//        guard !slots.isEmpty else {
//            print("No slots.")
//            return
//        }
//        
//        let slot = slots[0]
//        
//        print("state: \(slot.state)")
//        switch slot.state {
//        case .missing:
//            print("state: missing")
//        case .empty:
//            print("state: empty")
//        case .probing:
//            print("state: probing")
//        case .muteCard:
//            print("state: muteCard")
//        case .validCard:
//            print("state: validCard")
//        default:
//            print("state: unknown")
//        }
//        
//        print("name: \(slot.name)")
//        print("maxInputLength: \(slot.maxInputLength)")
//        print("maxOutputLength: \(slot.maxOutputLength)")
//        
//        guard let card = slot.makeSmartCard() else {
//            return
//        }
//        print("card: \(card)")
//
//        let success = try await card.beginSession()
//        assert(success)
//        defer {
//            card.endSession()
//        }
//        
//        print("isValid: \(card.isValid)")
//        let currentProtocol = card.currentProtocol
//        switch currentProtocol {
//        case .t0:
//            print("currentProtocol: T=0")
//        case .t1:
//            print("currentProtocol: T=1")
//        case .t15:
//            print("currentProtocol: T=15")
//        default:
//            print("currentProtocol: unknown")
//        }
//        
//        if let atr = slot.atr {
//            print("atr: \(atr)")
//            print("  protocols: \(atr.protocols), bytes: \(atr.bytes.hex), historicalBytes: \(atr.historicalBytes.hex), historicalRecords: \(atr.historicalRecords†)")
//            if let interfaceGroup = atr.interfaceGroup(for: currentProtocol) {
//                print("interfaceGroup: \(interfaceGroup)")
//                print("  protocol: \(interfaceGroup.protocol†), ta: \(interfaceGroup.ta†), tb: \(interfaceGroup.tb†), tc: \(interfaceGroup.tc†)")
//            }
//        }
//
//        do {
//            let uid = try await card.performRequest(Data([0xff, 0xca, 0x00, 0x00, 0x00]))
//            print("Card UID: \(uid.hex)")
//            
//            // Read the card's "Capability Container" (CC):
//            let cc = try await card.performRequest(Data([0xff, 0xb0, 0x04, 0x00, 0x04]))
//            print(cc.hex)
//
////            let selectNDEFCommand = Data([0x00, 0xA4, 0x04, 0x00, 0x07, 0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01, 0x00])
////            let data = try await card.performRequest(selectNDEFCommand)
////            print("NDEF application selected successfully \(data.hex)")
//
//        } catch let error as NSError {
//            print("Error: \(error.localizedDescription) - \(error)")
//        }
//    }
//}
//
//extension TKSmartCard {
//    @discardableResult
//    func performRequest(_ request: Data) async throws -> Data {
//        let response = try await transmit(request)
//
//        guard response.count >= 2 else {
//            throw APDUError.invalidResponseLength(response)
//        }
//        
//        let statusWord = UInt16(response[response.count - 2]) << 8 | UInt16(response[response.count - 1])
//        let data = response.prefix(response.count - 2)
//        
//        if statusWord == 0x9000 {
//            return data
//        } else {
//            throw APDUError(statusWord: statusWord)
//        }
//    }
//}
//
//enum APDUError: Error, LocalizedError {
//    case invalidResponseLength(Data)
//
//    // Specific error cases with no associated data
//    case wrongLength
//    case securityStatusNotSatisfied
//    case conditionsOfUseNotSatisfied
//    case fileNotFound
//    case recordNotFound
//    case incorrectParameters
//    case commandNotAllowed
//    case invalidInstruction
//    case classNotSupported
//    case unknownError
//
//    // Cases with associated data for variable status words
//    case warningNonVolatileMemoryUnchanged(Int) // 0x62XX where XX is the associated value
//    case warningNonVolatileMemoryChanged(Int)   // 0x63CX where X is the associated value
//    case wrongLengthExpected(Int)               // 0x6CXX where XX indicates expected length
//
//    // Fallback for unknown status words
//    case unknown(UInt16)
//
//    // Throwing initializer to parse the APDU response
//    init(statusWord: UInt16) {
//        // Initialize based on the status word
//        switch statusWord {
//        case 0x6700:
//            self = .wrongLength
//        case 0x6982:
//            self = .securityStatusNotSatisfied
//        case 0x6985:
//            self = .conditionsOfUseNotSatisfied
//        case 0x6A82:
//            self = .fileNotFound
//        case 0x6A83:
//            self = .recordNotFound
//        case 0x6A86:
//            self = .incorrectParameters
//        case 0x6986:
//            self = .commandNotAllowed
//        case 0x6D00:
//            self = .invalidInstruction
//        case 0x6E00:
//            self = .classNotSupported
//        case 0x6F00:
//            self = .unknownError
//        case let status where status & 0xFF00 == 0x6200:
//            self = .warningNonVolatileMemoryUnchanged(Int(status & 0x00FF))
//        case let status where status & 0xFF00 == 0x6300:
//            self = .warningNonVolatileMemoryChanged(Int(status & 0x00FF))
//        case let status where status & 0xFF00 == 0x6C00:
//            self = .wrongLengthExpected(Int(status & 0x00FF))
//        default:
//            self = .unknown(statusWord)
//        }
//    }
//
//    // Description for debugging or logging
//    var errorDescription: String? {
//        switch self {
//        case .invalidResponseLength(let data):
//            return "Invalid APDU response length: \(data.hex)"
//        case .wrongLength:
//            return "Wrong Length"
//        case .securityStatusNotSatisfied:
//            return "Security status not satisfied"
//        case .conditionsOfUseNotSatisfied:
//            return "Conditions of use not satisfied"
//        case .fileNotFound:
//            return "File not found"
//        case .recordNotFound:
//            return "Record not found"
//        case .incorrectParameters:
//            return "Incorrect parameters"
//        case .commandNotAllowed:
//            return "Command not allowed"
//        case .invalidInstruction:
//            return "Invalid instruction"
//        case .classNotSupported:
//            return "Class not supported"
//        case .unknownError:
//            return "Unknown error"
//        case .warningNonVolatileMemoryUnchanged(let value):
//            return "Warning: Non-volatile memory unchanged (Code: \(value.hex))"
//        case .warningNonVolatileMemoryChanged(let value):
//            return "Warning: Non-volatile memory changed (Retries: \(value))"
//        case .wrongLengthExpected(let expectedLength):
//            return "Wrong Length, expected: \(expectedLength) bytes"
//        case .unknown(let statusWord):
//            return "Unknown status word: \(statusWord.hex)"
//        }
//    }
//}

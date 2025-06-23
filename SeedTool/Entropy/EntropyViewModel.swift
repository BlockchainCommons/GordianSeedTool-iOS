//
//  EntropyViewModel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import WolfBase

final class EntropyViewModel<KeypadType>: ObservableObject where KeypadType: Keypad {
    @Published private(set) var values: [KeypadType.TokenType] = []
    @Published private(set) var isEmpty: Bool = true
    @Published private(set) var canPaste: Bool = false
    @Published private(set) var entropyBits: Double = 0
    @Published private(set) var entropyProgress: Double = 0
    @Published private(set) var entropyStrength: EntropyStrength = .veryWeak
    @Published private(set) var entropyColor: Color = EntropyStrength.veryWeak.color
    @Published private(set) var validationMessage: Text?

    private var bag: Set<AnyCancellable> = []
    
    func setValues(_ values: [KeypadType.TokenType]) {
        self.values = values
        syncToValues()
    }
    
    func clearValues() {
        self.values = []
        syncToValues()
    }
    
    func appendValue(_ value: KeypadType.TokenType) {
        self.values.append(value)
        syncToValues()
    }
    
    func removeLastValue() {
        self.values.removeLast()
        syncToValues()
    }
    
    private func syncToValues() {
        isEmpty = values.isEmpty
        entropyBits = Double(values.count) * KeypadType.entropyBitsPerValue
        entropyProgress = scale(domain: 0..128, range: 0..1)(entropyBits).clamped()
        entropyStrength = EntropyStrength.categorize(entropyBits)
        entropyColor = entropyStrength.color
        validationMessage = KeypadType.validate(values: values)
    }

    init() {
        syncCanPaste()
        NotificationCenter.default
            .publisher(for: UIPasteboard.changedNotification, object: UIPasteboard.general)
            .sink { [weak self] _ in self?.syncCanPaste()}
            .store(in: &bag)
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.syncCanPaste()}
            .store(in: &bag)
    }

    private func syncCanPaste() {
        self.canPaste = UIPasteboard.general.hasStrings
    }

    var seed: ModelSeed {
        let seed = ModelSeed(data: KeypadType.seed(values: values))!
        if KeypadType.setsCreationDate {
            seed.creationDate = Date()
        }
        return seed
    }
}

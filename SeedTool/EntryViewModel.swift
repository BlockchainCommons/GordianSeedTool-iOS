//
//  KeypadViewModel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import Interpolate

final class KeypadViewModel<KeypadType>: ObservableObject where KeypadType: Keypad {
    @Published var values: [KeypadType.DisplayValue] = [] {
        didSet {
            isEmpty = values.isEmpty
            entropyBits = Double(values.count) * KeypadType.entropyBitsPerValue
            entropyProgress = entropyBits.reverseInterpolate(from: (0, 128)).clamped
            entropyStrength = EntropyStrength.categorize(entropyBits)
            entropyColor = entropyStrength.color
        }
    }
    @Published var isEmpty: Bool = true
    @Published private(set) var canPaste: Bool = false
    @Published var entropyBits: Double = 0
    @Published var entropyProgress: Double = 0
    @Published var entropyStrength: EntropyStrength = .veryWeak
    @Published var entropyColor: Color = EntropyStrength.veryWeak.color

    private var bag: Set<AnyCancellable> = []

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
        //print("canPaste: \(self.canPaste)")
    }
}

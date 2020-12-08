//
//  EntryViewModel.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation
import Combine
import UIKit

final class EntryViewModel<KeypadType>: ObservableObject where KeypadType: Keypad {
    typealias Value = KeypadType.Value
    @Published var values: [Value] = [] {
        didSet {
            isEmpty = values.isEmpty
        }
    }
    @Published var isEmpty: Bool = true
    @Published private(set) var canPaste: Bool = false

//    deinit {
//        print("\(self) deinit")
//    }

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

    func append(_ value: Value) {
        values.append(value)
    }

    func removeLast() {
        values.removeLast()
    }
}

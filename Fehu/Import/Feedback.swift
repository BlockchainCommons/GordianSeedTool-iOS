//
//  Feedback.swift
//  Fehu
//
//  Created by Wolf McNally on 12/24/20.
//

import Foundation
import URUI

struct Feedback {
    static let beep1 = FeedbackGenerator(haptic: .heavy, soundFile: "beep1.mp3", subdirectory: "Sounds")
    static let beep2 = FeedbackGenerator(haptic: .heavy, soundFile: "beep2.mp3", subdirectory: "Sounds")
    static let beep3 = FeedbackGenerator(haptic: .heavy, soundFile: "beep3.mp3", subdirectory: "Sounds")
    static let beep4 = FeedbackGenerator(haptic: .success, soundFile: "beep4.mp3", subdirectory: "Sounds")
    static let beepError = FeedbackGenerator(haptic: .error, soundFile: "beepError.mp3", subdirectory: "Sounds")
    static let click = FeedbackGenerator(haptic: .light, soundFile: "click.caf", subdirectory: "Sounds")

    static let unlock = FeedbackGenerator(haptic: .medium, soundFile: "unlock.mp3", subdirectory: "Sounds")
    static let lock = FeedbackGenerator(haptic: .medium, soundFile: "lock.mp3", subdirectory: "Sounds")
    
    static let copy = FeedbackGenerator(haptic: .heavy)
    static let update = FeedbackGenerator(haptic: .heavy)
}

extension Feedback: URScanFeedbackProvider {
    func progress() {
        Self.click.play()
    }

    func success() {
        Self.beep4.play()
    }

    func error() {
        Self.beepError.play()
    }
}

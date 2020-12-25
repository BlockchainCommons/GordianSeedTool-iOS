//
//  FeedbackGenerator.swift
//  Fehu
//
//  Created by Wolf McNally on 12/24/20.
//

import AudioToolbox
import UIKit

public class FeedbackGenerator {
    private let haptic: Haptic?
    private let feedbackGenerator: Any? //UIFeedbackGenerator?
    private let soundID: SystemSoundID?

    public enum Haptic {
        case selection
        case heavy
        case medium
        case light
        case error
        case success
        case warning
    }

    public init(haptic: Haptic? = nil, soundFile: String? = nil, subdirectory: String? = nil) {
        self.haptic = haptic
        if let haptic = haptic {
            if #available(iOS 10.0, *) {
                switch haptic {
                case .selection:
                    feedbackGenerator = UISelectionFeedbackGenerator()
                case .heavy:
                    feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
                case .medium:
                    feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                case .light:
                    feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                case .error, .success, .warning:
                    feedbackGenerator = UINotificationFeedbackGenerator()
                }
            } else {
                feedbackGenerator = nil
            }
        } else {
            feedbackGenerator = nil
        }

        if let soundFile = soundFile, let url = Bundle.main.url(forResource: soundFile, withExtension: nil, subdirectory: subdirectory) {
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            self.soundID = soundID
        } else {
            soundID = nil
        }
    }

    public func play() {
        if let haptic = haptic {
            if #available(iOS 10.0, *) {
                switch haptic {
                case .selection:
                    (feedbackGenerator as! UISelectionFeedbackGenerator).selectionChanged()
                case .heavy, .medium, .light:
                    (feedbackGenerator as! UIImpactFeedbackGenerator).impactOccurred()
                case .error:
                    (feedbackGenerator as! UINotificationFeedbackGenerator).notificationOccurred(.error)
                case .success:
                    (feedbackGenerator as! UINotificationFeedbackGenerator).notificationOccurred(.success)
                case .warning:
                    (feedbackGenerator as! UINotificationFeedbackGenerator).notificationOccurred(.warning)
                }
            }
        }
        if let soundID = soundID {
            AudioServicesPlaySystemSound(soundID)
        }
    }

    deinit {
        if let soundID = soundID {
            AudioServicesDisposeSystemSoundID(soundID)
        }
    }
}

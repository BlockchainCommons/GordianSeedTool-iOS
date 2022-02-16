//
//  PasteboardActivity.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/15/22.
//

import UIKit
import SwiftUI

class PasteboardActivity: UIActivity {
    var activityItems: [Any]?
    
    override class var activityCategory: UIActivity.Category {
        .action
    }

    override var activityType: UIActivity.ActivityType? {
        .copyToPasteboard
    }
    
    override var activityTitle: String? {
        "Copy to Clipboard"
    }
    
    override var activityImage: UIImage? {
        UIImage(systemName: "doc.on.doc")!
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        let result =
        activityItems.first(where: { $0 is ActivityStringSource }) != nil ||
        activityItems.first(where: { $0 is ActivityImageSource }) != nil ||
        activityItems.first(where: { $0 is UIImage }) != nil ||
        activityItems.first(where: { $0 is String }) != nil ||
        false
        
        return result
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems
    }
    
    override func perform() {
        guard let item = activityItems?.first else {
            return
        }
        var success = true
        if let source = item as? ActivityStringSource {
            PasteboardCoordinator.shared.copyToPasteboard(source.string)
        } else if let source = item as? ActivityImageSource {
            PasteboardCoordinator.shared.copyToPasteboard(source.image)
        } else if let image = item as? UIImage {
            PasteboardCoordinator.shared.copyToPasteboard(image)
        } else if let string = item as? String {
            PasteboardCoordinator.shared.copyToPasteboard(string)
        } else {
            print("⛔️ Unknown activityItem: \(item)")
            success = false
        }
        activityItems = nil
        activityDidFinish(success)
    }
}

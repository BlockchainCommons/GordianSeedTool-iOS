//
//  Authentication.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 1/16/21.
//

import LocalAuthentication
import SwiftUI
import Dispatch

final class Authentication: ObservableObject {
    @Published var isUnlocked: Bool = false

    func attemptUnlock(reason: String) {
        guard !isUnlocked else { return }

        let context = LAContext()

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print("Cannot authenticate: \(String(describing: error))")
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                guard success else {
                    print("Authentication failed: \(String(describing: error))")
                    return
                }
                
                self.isUnlocked = true
            }
        }
    }
    
    func lock() {
        guard isUnlocked else { return }
        self.isUnlocked = false
    }
}

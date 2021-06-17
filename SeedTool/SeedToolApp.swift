//
//  SeedToolApp.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI
import UserNotifications
import CloudKit

let isTakingSnapshot = ProcessInfo.processInfo.arguments.contains("SNAPSHOT")
let settings = Settings(storage: UserDefaults.standard)
let model = Model.load()
let cloud = Cloud(model: model, settings: settings)

@main
struct SeedToolApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tapToDismiss()
                .environmentObject(model)
                .environmentObject(settings)
                .environmentObject(cloud)
                .onAppear {
                    disableHardwareKeyboards()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UISceneDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let _ = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            print("CloudKit database changed.")
            cloud.fetchChanges { result in
                switch result {
                case .success:
                    //print("✅ Fetched changes.")
                    completionHandler(.newData)
                case .failure(let error):
                    print("⛔️ Failed to fetch changes: \(error).")
                    completionHandler(.failed)
                }
            }
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        cloud.fetchChanges { _ in
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: .windowApplication)
        config.delegateClass = AppDelegate.self
        return config
    }
}

/// Necessary for XCUI automation.
/// https://stackoverflow.com/a/57618331/2413963
func disableHardwareKeyboards() {
    #if targetEnvironment(simulator)
    let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
    UITextInputMode.activeInputModes
        // Filter `UIKeyboardInputMode`s.
        .filter({ $0.responds(to: setHardwareLayout) })
        .forEach { $0.perform(setHardwareLayout, with: nil) }
    #endif
}

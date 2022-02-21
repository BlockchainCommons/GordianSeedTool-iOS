//
//  SeedToolApp.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI
import UserNotifications
import CloudKit
import Combine
import WolfBase

let isTakingSnapshot = ProcessInfo.processInfo.arguments.contains("SNAPSHOT")
let needsFetchPublisher = PassthroughSubject<(UIBackgroundFetchResult) -> Void, Never>()

@main
struct SeedToolApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var model: Model
    @StateObject private var settings: Settings
    
    init() {
        let settings = Settings(storage: UserDefaults.standard)
        let model = Model(settings: settings)
        self._settings = StateObject(wrappedValue: settings)
        self._model = StateObject(wrappedValue: model)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tapToDismiss()
                .environmentObject(model)
                .environmentObject(settings)
                .onAppear {
                    disableHardwareKeyboards()
                }
                .onReceive(needsFetchPublisher) { completionHandler in
                    model.fetchChanges { result in
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
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UISceneDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("✅ willFinishLaunchingWithOptions: \(launchOptions†)")
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("✅ didFinishLaunchingWithOptions: \(launchOptions†)")
        #if !targetEnvironment(simulator)
        UIApplication.shared.registerForRemoteNotifications()
        #endif
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ Registered for remote notifications.")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("⛔️ Could not register for remote notifications: \(error).")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let _ = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            print("☁️ CloudKit database changed.")
            needsFetchPublisher.send(completionHandler)
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: .windowApplication)
        config.delegateClass = AppDelegate.self
        return config
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("🟣 applicationDidBecomeActive")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("🟣 applicationWillResignActive")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("🟣 applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("🟣 applicationWillEnterForeground")
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("🟢 sceneDidEnterBackground")
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print("🟢 sceneDidDisconnect")
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("🟢 sceneWillResignActive")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("🟢 sceneWillEnterForeground")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("🟢 sceneDidBecomeActive.")
        needsFetchPublisher.send { _ in
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("🔥 openURLContexts: \(URLContexts)")
    }

    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        print("🟡 applicationProtectedDataDidBecomeAvailable")
    }
    
    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        print("🟡 applicationProtectedDataWillBecomeUnavailable")
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

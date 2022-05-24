//
//  AppDelegate.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/24/22.
//

import UIKit
import os
import WolfBase
import CloudKit
import BCApp

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "AppDelegate")

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        logger.debug("✅ didFinishLaunchingWithOptions: \(launchOptions†)")
        #if !targetEnvironment(simulator)
        UIApplication.shared.registerForRemoteNotifications()
        #endif
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        logger.debug("✅ Registered for remote notifications.")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.debug("⛔️ Could not register for remote notifications: \(error.localizedDescription).")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let _ = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            logger.debug("☁️ CloudKit database changed.")
            needsFetchPublisher.send(completionHandler)
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: .windowApplication)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

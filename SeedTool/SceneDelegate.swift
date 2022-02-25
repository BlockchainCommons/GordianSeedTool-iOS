//
//  SceneDelegate.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/24/22.
//

import UIKit
import os
import WolfBase

fileprivate let logger = Logger(subsystem: bundleIdentifier, category: "SceneDelegate")

class SceneDelegate: NSObject, UISceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        logger.debug("🟢 sceneWillConnectTo: \(session†) options: \(connectionOptions†)")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        logger.debug("🟢 sceneDidEnterBackground")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        logger.debug("🟢 sceneDidDisconnect")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        logger.debug("🟢 sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        logger.debug("🟢 sceneWillEnterForeground")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        logger.debug("🟢 sceneDidBecomeActive.")
        needsFetchPublisher.send { _ in }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        logger.debug("🟢 openURLContexts")
        NavigationManager.send(url: URLContexts.first!.url)
    }

    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        logger.debug("🟢 applicationProtectedDataDidBecomeAvailable")
    }

    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        logger.debug("🟢 applicationProtectedDataWillBecomeUnavailable")
    }
}

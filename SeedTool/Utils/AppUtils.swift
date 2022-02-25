//
//  AppUtils.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/2/21.
//

import Foundation
import UIKit
import SwiftUI
import os

struct Application {
    static let version: String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }()
    
    static let buildNumber: String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }()
    
    static let fullVersion: String = {
        "\(version) (\(buildNumber))"
    }()
    
    static let isAppSandbox: Bool = {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }()
    
    static let isDebug: Bool = {
    #if DEBUG
        true
    #else
        false
    #endif
    }()
    
    static let isSimulator: Bool = {
    #if targetEnvironment(simulator)
        true
    #else
        false
    #endif
    }()
    
    static let isCatalyst: Bool = {
    #if targetEnvironment(macCatalyst)
        true
    #else
        false
    #endif
    }()
    
    static let isAPNSSandbox: Bool = {
        #if targetEnvironment(macCatalyst)
        var p = URL(fileURLWithPath: Bundle.main.bundlePath)
        p.appendPathComponent("Contents", isDirectory: true)
        p.appendPathComponent("embedded.provisionprofile")
        let filePath = p.path
        #else
        guard let filePath = Bundle.main.path(forResource: "embedded", ofType:"mobileprovision") else {
            return false
        }
        #endif
        do {
            let url = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .ascii) else {
                return false
            }
            if string.contains("<key>aps-environment</key>\n\t\t<string>development</string>") {
                return true
            }
        } catch {
            Logger().log("⛔️ \(error.localizedDescription)")
        }
        return false
    }()
    
    static let isCloudSandbox: Bool = {
        let container = Cloud.container
        let containerID = container.value(forKey: "containerID") as! NSObject
        let environment = containerID.value(forKey: "environment")! as! CLongLong
        return environment == 2
    }()
    
    static let buildInfoList: [String] = {
        let elems: [String?] = [
            isDebug ? "Debug" : nil,
            isSimulator ? "Simulator" : nil,
            isAppSandbox ? "App Sandbox" : nil,
            isAPNSSandbox ? "APNS Sandbox" : nil,
            isCloudSandbox ? "iCloud Sandbox" : nil,
        ]
        return elems.compactMap { $0 }
    }()
    
    static let buildInfo: String = {
        buildInfoList.joined(separator: ", ")
    }()
    
    static let versionInfoBlock: String = {
        [fullVersion, buildInfo].joined(separator: "\n")
    }()
}

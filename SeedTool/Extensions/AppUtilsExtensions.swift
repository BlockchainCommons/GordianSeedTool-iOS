//
//  AppUtilsExtensions.swift
//  SeedTool
//
//  Created by Wolf McNally on 5/23/22.
//

import Foundation
import BCApp

extension Application {
    public static let maxFragmentLen = 600

    public static let isCloudSandbox: Bool = {
        let container = Cloud.container
        let containerID = container.value(forKey: "containerID") as! NSObject
        let environment = containerID.value(forKey: "environment")! as! CLongLong
        return environment == 2
    }()
    
    public static let buildInfoList: [String] = {
        let elems: [String?] = [
            isDebug ? "Debug" : nil,
            isSimulator ? "Simulator" : nil,
            isAppSandbox ? "App Sandbox" : nil,
            isAPNSSandbox ? "APNS Sandbox" : nil,
            isCloudSandbox ? "iCloud Sandbox" : nil,
        ]
        return elems.compactMap { $0 }
    }()
    
    public static let buildInfo: String = {
        buildInfoList.joined(separator: ", ")
    }()
    
    public static let versionInfoBlock: String = {
        [fullVersion, buildInfo].joined(separator: "\n")
    }()
}

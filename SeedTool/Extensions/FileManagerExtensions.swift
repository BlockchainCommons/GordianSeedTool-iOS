//
//  FileManagerExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation

extension FileManager {
    static var documentDirectory: URL {
        `default`.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

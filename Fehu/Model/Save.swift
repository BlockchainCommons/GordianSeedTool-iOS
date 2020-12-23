//
//  Save.swift
//  Fehu
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation

protocol Saveable: Codable & Identifiable {
    func save()
    func delete()
    static func load(id: ID) throws -> Self

    static var saveType: String { get }
}

extension Saveable where ID: CustomStringConvertible {
    private static var dir: URL {
        FileManager.documentDirectory.appendingPathComponent(Self.saveType)
    }

    private static func file(for id: ID) -> URL {
        let filename = id.description
        return dir.appendingPathComponent(filename).appendingPathExtension("json")
    }

    func save() {
        do {
            try FileManager.default.createDirectory(at: Self.dir, withIntermediateDirectories: true)
            let json = try JSONEncoder().encode(self)
            let file = Self.file(for: id)
            try json.write(to: file, options: [.atomic, .completeFileProtection])
            print("✅ \(Date()) Saved: \(file.path)")
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func delete() {
        do {
            let file = Self.file(for: id)
            try FileManager.default.removeItem(at: file)
//            print("⛔️ \(Date()) Deleted: \(file.path)")
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    static func load(id: ID) throws -> Self {
        let file = Self.file(for: id)
        let json = try Data(contentsOf: file)
        let result = try JSONDecoder().decode(Self.self, from: json)
//            print("🔵 \(Date()) Loaded: \(file.path)")
        return result
    }
}

extension Array where Element: Codable {
    func save(name: String) {
        do {
            let dir = FileManager.documentDirectory
            let file = dir.appendingPathComponent(name).appendingPathExtension("json")
            let json = try JSONEncoder().encode(self)
            try json.write(to: file, options: [.atomic, .completeFileProtection])
//            print("✅ \(Date()) Saved: \(file.path)")
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    static func load(name: String) -> Self? {
        do {
            let dir = FileManager.documentDirectory
            let file = dir.appendingPathComponent(name).appendingPathExtension("json")
            let json = try Data(contentsOf: file)
            let result = try JSONDecoder().decode(Self.self, from: json)
//            print("🔵 \(Date()) Loaded: \(file.path)")
            return result
        } catch {
            return nil
        }
    }
}

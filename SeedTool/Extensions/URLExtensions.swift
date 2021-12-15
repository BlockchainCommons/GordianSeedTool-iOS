//
//  URLExtensions.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/12/21.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

extension UTType {
    static var psbt = UTType("com.blockchaincommons.psbt")!
}

extension URL: ImageLoader {
    var isImage: Bool {
        (try? resourceValues(forKeys: [.contentTypeKey]).contentType?.conforms(to: .image)) ?? false
    }
    
    var isPSBT: Bool {
        (try? resourceValues(forKeys: [.contentTypeKey]).contentType?.conforms(to: .psbt)) ?? false
    }
    
    func loadImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                let image = try loadImageSync()
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    // Don't call from main thread
    func loadImageSync() throws -> UIImage {
        _ = self.startAccessingSecurityScopedResource()
        defer {
            self.stopAccessingSecurityScopedResource()
        }
        guard let data = try? Data(contentsOf: self) else {
            throw GeneralError("Could not read data for: \(self)")
        }
        guard let image = UIImage(data: data) else {
            throw GeneralError("Could not form image from data at: \(self)")
        }
        return image
    }
}

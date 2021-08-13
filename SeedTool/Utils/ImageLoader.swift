//
//  ImageLoader.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/12/21.
//

import Foundation
import UIKit

protocol ImageLoader {
    func loadImage(completion: @escaping (Result<UIImage, Error>) -> Void)
}

func extractQRCodes<T>(from imageLoaders: [T], completion: @escaping ([String]) -> Void) where T: ImageLoader {
    var messages: [String] = []
    var remaining = imageLoaders.makeIterator()
    
    processNext()
    
    func processNext() {
        guard let loader = remaining.next() else {
            DispatchQueue.main.async {
                completion(messages)
            }
            return
        }
        loader.loadImage { result in
            switch result {
            case .success(let image):
                image.detectQRCodes { result in
                    switch result {
                    case .success(let m):
                        DispatchQueue.main.async {
                            messages.append(contentsOf: m)
                        }
                    case .failure(let error):
                        print("⛔️ \(error)")
                    }
                    DispatchQueue.main.async {
                        processNext()
                    }
                }
            case .failure(let error):
                print("⛔️ \(error)")
                DispatchQueue.main.async {
                    processNext()
                }
            }
        }
    }
}

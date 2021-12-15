//
//  ImageExtensions.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/12/21.
//

import UIKit

extension UIImage {
    func detectQRCodes(completion: @escaping (Result<[String], Error>) -> Void) {
        DispatchQueue.global().async {
            guard let image = CIImage(image: self) else {
                completion(.failure(GeneralError("Could not convert image to CIImage.")))
                return
            }
            
            let options = [
                CIDetectorAccuracy: CIDetectorAccuracyHigh,
                CIDetectorImageOrientation: image.properties[kCGImagePropertyOrientation as String] ?? 1
            ]
            guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options) else {
                completion(.failure(GeneralError("Could not create QR code detector.")))
                return
            }
            
            let messages = detector.features(in: image, options: options).compactMap { feature in
                (feature as? CIQRCodeFeature)?.messageString
            }
            completion(.success(messages))
        }
    }
}

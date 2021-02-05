//
//  ImageUtils.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 1/18/21.
//

import UIKit

extension UIImage {
    func resized(to targetSize: CGSize, interpolationQuality: CGInterpolationQuality = .none) -> UIImage {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = interpolationQuality
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func scaled(by scale: CGFloat, interpolationQuality: CGInterpolationQuality = .none) -> UIImage {
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resized(to: scaledSize, interpolationQuality: interpolationQuality)
    }
}

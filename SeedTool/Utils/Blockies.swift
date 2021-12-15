//
//  Blockies.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/16/21.
//
//  Based on BlockiesSwift
//  https://github.com/Boilertalk/BlockiesSwift
//

import Foundation
import UIKit
import SwiftUI

public struct BlockiesView: View {
    let seed: Data
    
    public var body: some View {
        return Image(uiImage: Blockies.image(for: seed))
            .interpolation(.none)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

public final class Blockies {
    // MARK: - Properties
    private var randSeed: [UInt32]
    
    public var seed: Data
    
    public var size: Int
    public var scale: Int
    
    public var color: UIColor
    public var bgColor: UIColor
    public var spotColor: UIColor
    
    public static func image(for seed: Data) -> UIImage {
        Blockies(seed: seed).createImage()
    }
    
    // MARK: - Initialization
    /**
     * Initializes this instance of `Blockies` with the given values or default values.
     *
     * - parameter seed: The seed to be used for this Blockies. Defaults to random.
     * - parameter size: The number of blocks per side for this image. Defaults to 8.
     * - parameter scale: The number of pixels per block. Defaults to 4.
     * - parameter color: The foreground color. Defaults to random.
     * - parameter bgColor: The background color. Defaults to random.
     * - parameter spotColor: A color which forms mouths and eyes. Defaults to random.
     */
    public init(
        seed: Data,
        size: Int = 8,
        scale: Int = 4,
        color: UIColor? = nil,
        bgColor: UIColor? = nil,
        spotColor: UIColor? = nil
    ) {
        self.seed = seed
        self.randSeed = BlockiesHelper.createRandSeed(seed: seed)
        self.size = size
        self.scale = scale
        self.color = color ?? UIColor()
        self.bgColor = bgColor ?? UIColor()
        self.spotColor = spotColor ?? UIColor()
        
        if color == nil {
            self.color = createColor()
        }
        if bgColor == nil {
            self.bgColor = createColor()
        }
        if spotColor == nil {
            self.spotColor = createColor()
        }
    }
    
    /**
     * Creates the Blockies Image with currently set values.
     *
     * You can change the absolute size in pixels of the resulting image
     * by passing a `customScale` value which will result in the total pixel size
     * calculated as follows:
     *
     * `size * scale * customScale`
     *
     * For example: Default values `size = 8` and `scale = 4` result in an image
     * with 32x32px size. If you provide a `customScale` of `10`, you will get
     * an image with 320x320px in size.
     *
     * - parameter customScale: A scale factor which will be used to calculate the total image size.
     *
     * - returns: The generated image or `nil` if something went wrong.
     */
    public func createImage(customScale: Int = 1) -> UIImage {
        let imageData = createImageData()
        
        return image(data: imageData, customScale: customScale)
    }
    
    private func rand() -> Double {
        let t = randSeed[0] ^ (randSeed[0] << 11)
        
        randSeed[0] = randSeed[1]
        randSeed[1] = randSeed[2]
        randSeed[2] = randSeed[3]
        let tmp = Int32(bitPattern: randSeed[3])
        let tmpT = Int32(bitPattern: t)
        randSeed[3] = UInt32(bitPattern: (tmp ^ (tmp >> 19) ^ tmpT ^ (tmpT >> 8)))
        
        // UInt for zero fill right shift
        // let divisor = (UInt32((1 << 31)) >> UInt32(0))
        let divisor = Int32.max
        
        return Double((UInt32(randSeed[3]) >> UInt32(0))) / Double(divisor)
    }
    
    private func createColor() -> UIColor {
        let h = Double(rand() * 360)
        let s = Double(((rand() * 60) + 40)) / Double(100)
        let l = Double((rand() + rand() + rand() + rand()) * 25) / Double(100)
        
        return UIColor(h: h, s: s, l: l) ?? UIColor.black
    }
    
    private func createImageData() -> [Double] {
        let width = size
        let height = size
        
        let dataWidth = Int(ceil(Double(width) / Double(2)))
        let mirrorWidth = width - dataWidth
        
        var data: [Double] = []
        for _ in 0 ..< height {
            var row = [Double](repeating: 0, count: dataWidth)
            for x in 0 ..< dataWidth {
                // this makes foreground and background color to have a 43% (1/2.3) probability
                // spot color has 13% chance
                row[x] = floor(Double(rand()) * 2.3)
            }
            let r = [Double](row[0 ..< mirrorWidth]).reversed()
            row.append(contentsOf: r)
            
            for i in 0 ..< row.count {
                data.append(row[i])
            }
        }
        
        return data
    }
    
    private func image(data: [Double], customScale: Int) -> UIImage {
        let finalSize = size * scale * customScale
        UIGraphicsBeginImageContext(CGSize(width: finalSize, height: finalSize))
        let context = UIGraphicsGetCurrentContext()!
        
        let width = Int(sqrt(Double(data.count)))
        
        context.setFillColor(bgColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size * scale, height: size * scale))
        
        for i in 0 ..< data.count {
            let row = Int(floor(Double(i) / Double(width)))
            let col = i % width
            
            let number = data[i]
            
            let uiColor: UIColor
            if number == 0 {
                uiColor = bgColor
            } else if number == 1 {
                uiColor = color
            } else if number == 2 {
                uiColor = spotColor
            } else {
                uiColor = UIColor.black
            }
            
            context.setFillColor(uiColor.cgColor)
            context.fill(CGRect(x: CGFloat(col * scale * customScale), y: CGFloat(row * scale * customScale), width: CGFloat(scale * customScale), height: CGFloat(scale * customScale)))
        }
        
        let output = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return output
    }
}

fileprivate class BlockiesHelper {
    
    /**
     * Creates the initial version of the 4 UInt32 array for the given seed.
     * The result is equal for equal seeds.
     *
     * - parameter seed: The seed.
     *
     * - returns: The UInt32 array with exactly 4 values stored in it.
     */
    fileprivate static func createRandSeed(seed: Data) -> [UInt32] {
        var randSeed = [UInt32](repeating: 0, count: 4)
        for i in 0 ..< seed.count {
            // &* and &- are the "overflow" operators. Need to be used there.
            // There is no overflow left shift operator so we do "&* pow(2, 5)" instead of "<< 5"
            randSeed[i % 4] = ((randSeed[i % 4] &* (2 << 4)) &- randSeed[i % 4])
            let index = seed.index(seed.startIndex, offsetBy: i)
            randSeed[i % 4] = randSeed[i % 4] &+ UInt32(seed[index])
        }
        
        return randSeed
    }
}

extension UIColor {
    /**
     * Initializes Color with the given HSL color values.
     *
     * H must be bigger than 0 and smaller than 360.
     *
     * S must be between 0 and 1.
     *
     * L must be between 0 and 1.
     *
     * - parameter h: The h value.
     * - parameter s: The s value.
     * - parameter l: The l value.
     */
    fileprivate convenience init?(h: Double, s: Double, l: Double) {
        let c = (1 - abs(2 * l - 1)) * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - (c / 2)

        let (tmpR, tmpG, tmpB): (Double, Double, Double)
        if 0 <= h && h < 60 {
            (tmpR, tmpG, tmpB) = (c, x, 0)
        } else if 60 <= h && h < 120 {
            (tmpR, tmpG, tmpB) = (x, c, 0)
        } else if 120 <= h && h < 180 {
            (tmpR, tmpG, tmpB) = (0, c, x)
        } else if 180 <= h && h < 240 {
            (tmpR, tmpG, tmpB) = (0, x, c)
        } else if 240 <= h && h < 300 {
            (tmpR, tmpG, tmpB) = (x, 0, c)
        } else if 300 <= h && h < 360 {
            (tmpR, tmpG, tmpB) = (c, 0, x)
        } else {
            return nil
        }

        let r = (tmpR + m)
        let g = (tmpG + m)
        let b = (tmpB + m)

        self.init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
    }

    fileprivate static func fromHSL(h: Double, s: Double, l: Double) -> UIColor? {
        return UIColor(h: h, s: s, l: l)
    }
}

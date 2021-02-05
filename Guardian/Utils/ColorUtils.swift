//
//  ColorUtils.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/20/20.
//

import UIKit
import UIImageColors
import WolfColor
import simd

func getMatchedColors(for image: UIImage, quality: UIImageColorsQuality = .high) -> MatchedImageColors? {
    guard let imageColors = image.getColors(quality: quality) else { return nil }
    return MatchedImageColors(
        background: ImageColorMatch(color: imageColors.background),
        primary: ImageColorMatch(color: imageColors.primary),
        secondary: ImageColorMatch(color: imageColors.secondary),
        detail: ImageColorMatch(color: imageColors.detail)
    )
}

extension Color {
    func distance(to other: Color) -> Double {
        let v1 = SIMD3<Double>(red, green, blue)
        let v2 = SIMD3<Double>(other.red, other.green, other.blue)
        let d = v2 - v1
        return simd_length(d)
    }
}

func closestNamedColor(to color: Color) -> NamedColor {
    var bestNamedColor: NamedColor!
    var bestDistance: Double = .infinity
    NamedColor.colors.forEach { namedColor in
        let d = color.distance(to: namedColor.color)
        if d < bestDistance {
            bestNamedColor = namedColor
            bestDistance = d
        }
    }
    return bestNamedColor
}

struct ImageColorMatch {
    let color: UIColor
    let namedColor: NamedColor

    init(color: UIColor) {
        self.color = color
        namedColor = closestNamedColor(to: Color(color))
    }
}

struct MatchedImageColors {
    let background: ImageColorMatch
    let primary: ImageColorMatch
    let secondary: ImageColorMatch
    let detail: ImageColorMatch
}

struct NamedColor: Decodable {
    let name: String
    let color: Color

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let colorString = try container.decode(String.self)
        color = try Color(string: colorString)
        name = try container.decode(String.self)
    }

    static let colors: [NamedColor] = {
        let url = Bundle.main.url(forResource: "NamedColors", withExtension: "json")!
        let data = try! Data.init(contentsOf: url)
        return try! JSONDecoder().decode([NamedColor].self, from: data)
    }()
}

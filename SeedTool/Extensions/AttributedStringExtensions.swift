import Foundation
import SwiftUI

extension AttributedString {
    init(_ string: String, color: Color, bold: Bool = false, textStyle: UIFont.TextStyle = .body, smallStyle: Bool = false) {
        var s = AttributedString(string)
        s.foregroundColor = color
        var fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        if bold {
            fontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) ?? fontDescriptor
        }
        let font = UIFont(descriptor: fontDescriptor, size: 0)
        s.font = font
        if smallStyle {
            let smallFont = UIFont(descriptor: font.fontDescriptor, size: font.pointSize / 2)
            s.font = smallFont
        }
        self = s
    }
    
    init(error: String) {
        self.init(error, color: .red, textStyle: .caption1)
    }
    
    init(warning: String) {
        self.init(warning, color: .yellowLightSafe, textStyle: .caption1)
    }
}

extension Array where Element == AttributedString {
    func joined(separator: String) -> AttributedString {
        let attributedSeparator = AttributedString(separator)
        var result = AttributedString()
        for (index, element) in self.enumerated() {
            result.append(element)
            if index < self.count - 1 {
                result.append(attributedSeparator)
            }
        }
        return result
    }
}

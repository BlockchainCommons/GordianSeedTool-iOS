//
//  Colors.swift
//  Guardian
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

extension UIColor {
    static let formGroupBackground = UIColor { (traits) -> UIColor in
        traits.userInterfaceStyle == .dark ?
            UIColor(white: 1, alpha: 0.1) :
            UIColor(white: 0, alpha: 0.1)
    }

    static let yellowLightSafe = UIColor { (traits) -> UIColor in
        traits.userInterfaceStyle == .dark ?
            UIColor.systemYellow :
            UIColor.systemOrange
    }
}

extension Color {
    static let formGroupBackground = Color(.formGroupBackground)
    static let yellowLightSafe = Color(.yellowLightSafe)
}

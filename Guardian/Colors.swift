//
//  Colors.swift
//  Guardian
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

extension UIColor {
    static let primaryBackground = UIColor { (traits) -> UIColor in
        traits.userInterfaceStyle == .dark ?
            UIColor(white: 0, alpha: 1) :
            UIColor(white: 1, alpha: 1)
    }

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
    
    static let darkGreenBackground = UIColor { (traits) -> UIColor in
        traits.userInterfaceStyle == .dark ?
            UIColor(red: 0, green: 0.5, blue: 0, alpha: 1) :
            UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
    }
    
    static let lightRedBackground = UIColor { (traits) -> UIColor in
        traits.userInterfaceStyle == .dark ?
            UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1) :
            UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1)
    }
}

extension Color {
    static let primaryBackground = Color(.primaryBackground)
    static let formGroupBackground = Color(.formGroupBackground)
    static let yellowLightSafe = Color(.yellowLightSafe)
    static let darkGreenBackground = Color(.darkGreenBackground)
    static let lightRedBackground = Color(.lightRedBackground)
}

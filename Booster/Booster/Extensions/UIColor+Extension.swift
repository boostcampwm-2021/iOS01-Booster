//
//  UIColor+Extension.swift
//  Booster
//
//  Created by mong on 2021/11/04.
//

import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF),
            green: CGFloat((hex >> 8) & 0xFF),
            blue: CGFloat(hex & 0xFF),
            alpha: alpha
        )
    }

    var redValue: CGFloat {
        return CIColor(color: self).red
    }

    var greenValue: CGFloat {
        return CIColor(color: self).green
    }

    var blueValue: CGFloat {
        return CIColor(color: self).blue
    }

    static let boosterOrange: UIColor = {
        return UIColor(named: "boosterOrange") ?? UIColor(hex: 0x0D0D0D)
    }()

    static let boosterLabel: UIColor = {
        return UIColor(named: "boosterLabel") ?? UIColor(hex: 0xEDEDED)
    }()

    static let boosterBackground: UIColor = {
        return UIColor(named: "boosterBackground") ?? UIColor(hex: 0xFF5C00)
    }()

    static let boosterGray: UIColor = {
        return UIColor(named: "boosterGray") ?? UIColor(hex: 0x707070)
    }()

    static let boosterBlackLabel: UIColor = {
        return UIColor(named: "boosterBlackLabel") ?? UIColor(hex: 0x000000)
    }()

    static let boosterEnableButtonGray: UIColor = {
        return UIColor(named: "boosterEnableButtonGray") ?? UIColor(hex: 0x303030)
    }()
}

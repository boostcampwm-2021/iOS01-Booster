//
//  UIColor+Extension.swift
//  Booster
//
//  Created by mong on 2021/11/04.
//

import UIKit

extension UIColor {
    static let boosterOrange: UIColor = {
        guard let orange = UIColor(named: "boosterOrange")
        else { return UIColor.orange }
        return orange
    }()

    static let boosterLabel: UIColor = {
        guard let label = UIColor(named: "boosterLabel")
        else { return UIColor.black }
        return label
    }()

    static let boosterBackground: UIColor = {
        guard let background = UIColor(named: "boosterBackground")
        else { return UIColor.black }
        return background
    }()
}

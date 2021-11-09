//
//  UIImage+Extension.swift
//  Booster
//
//  Created by hiju on 2021/11/09.
//

import UIKit

extension UIImage {
    enum AssetName: String {
        case foot
    }

    convenience init?(assetName: AssetName) {
        self.init(named: assetName.rawValue)
    }
}

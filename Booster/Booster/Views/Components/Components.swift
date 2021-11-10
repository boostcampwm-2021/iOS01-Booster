//
//  NavigationBackButton.swift
//  Booster
//
//  Created by mong on 2021/11/09.
//

import UIKit

struct Components {
    var backButton: UIButton = {
        let button = UIButton()
        button.imageView?.image = UIImage.arrowLeft
        button.tintColor = UIColor.boosterBackground

        return button
    }()
}

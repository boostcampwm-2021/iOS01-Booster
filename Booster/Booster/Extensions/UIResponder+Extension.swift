//
//  UIResponder+Extension.swift
//  Booster
//
//  Created by Hani on 2021/11/08.
//

import UIKit

extension UIResponder {
    static var identifier: String {
        String(describing: self)
    }
}

//
//  EnrollTextField.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/27.
//

import UIKit

class EnrollTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

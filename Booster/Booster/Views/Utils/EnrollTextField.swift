//
//  EnrollTextField.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/27.
//

import UIKit

final class EnrollTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

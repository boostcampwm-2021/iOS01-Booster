//
//  EnrollTextField.swift
//  Booster
//
//  Created by κΉνν on 2021/11/29.
//

import UIKit

final class EnrollTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

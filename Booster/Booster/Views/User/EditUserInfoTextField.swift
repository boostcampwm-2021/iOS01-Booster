//
//  EditUserInfoTextField.swift
//  Booster
//
//  Created by mong on 2021/11/18.
//

import UIKit

final class EditUserInfoTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    private func commonInit() {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
        border.backgroundColor = UIColor.boosterGray.cgColor
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}

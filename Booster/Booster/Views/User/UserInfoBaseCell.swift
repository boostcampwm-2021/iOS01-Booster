//
//  UserInfoBaseCell.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import UIKit

class UserInfoBaseCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

//
//  UserInfoBaseCell.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import UIKit

final class UserInfoBaseCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!

    static let cellHeight: CGFloat = 60

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

//
//  UserInfoHeaderView.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import UIKit

class UserInfoHeaderView: UITableViewHeaderFooterView {
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var userInfoLabel: UILabel!

    func configure(viewModel: UserViewModel) {
        nicknameLabel.text = viewModel.nickname()
        userInfoLabel.text = viewModel.userPhysicalInfo()
    }
}

//
//  UserInfoHeaderView.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import UIKit

final class UserInfoHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var nicknameLabel: UILabel!
    @IBOutlet private weak var userInfoLabel: UILabel!

    static let viewHeight: CGFloat = 200

    func configure(viewModel: UserViewModel) {
        nicknameLabel.text = viewModel.model.value.nickname
        userInfoLabel.text = viewModel.userPhysicalInfo()
    }
}

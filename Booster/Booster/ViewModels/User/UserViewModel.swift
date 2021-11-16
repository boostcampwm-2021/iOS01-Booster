//
//  UserViewModel.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import Foundation

final class UserViewModel {
    let userModel: UserInfo

    init() {
        userModel = UserInfo(age: 25, nickname: "히로롱", gender: "여", height: 164, weight: 80)
    }

    func nickname() -> String {
        return userModel.nickname
    }

    func userPhysicalInfo() -> String {
        return "\(userModel.age)살, \(userModel.height)cm, \(userModel.weight)kg, \(userModel.gender)"
    }
}

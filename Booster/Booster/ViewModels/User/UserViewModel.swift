//
//  UserViewModel.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import Foundation

final class UserViewModel {
    private let usecase: UserUsecase
    private var model: UserInfo

    init() {
        usecase = UserUsecase()
        model = UserInfo(age: 25, nickname: "히로롱", gender: "여", height: 164, weight: 80)
    }

    func nickname() -> String {
        return model.nickname
    }

    func userPhysicalInfo() -> String {
        return "\(model.age)살, \(model.height)cm, \(model.weight)kg, \(model.gender)"
    }

    func editUserInfo(gender: String? = nil, age: Int? = nil, height: Int? = nil, weight: Int? = nil, nickname: String? = nil) {
        if let gender = gender { model.gender = gender }
        if let age = age { model.age = age }
        if let height = height { model.height = height }
        if let weight = weight { model.weight = weight }
        if let nickname = nickname { model.nickname = nickname }
    }

    func save(completion: @escaping (Bool) -> Void) {
        usecase.editUserInfo(model: model) { (isSaved) in
            completion(isSaved)
        }
    }
}

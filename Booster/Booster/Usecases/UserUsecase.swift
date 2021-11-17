//
//  UserUsecase.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import Foundation

final class UserUsecase {
    private enum CoreDataKeys {
        static let age: String = "age"
        static let nickname: String = "nickname"
        static let gender: String = "gender"
        static let height: String = "height"
        static let weight: String = "weight"
    }

    private let repository = RepositoryManager()

    func removeAllUserData() {

    }

    func editUserInfo(model: UserInfo, completion: @escaping (Bool) -> Void) {
        let entity = "User"
        let value: [String: Any] = [
            CoreDataKeys.age: model.age,
            CoreDataKeys.nickname: model.nickname,
            CoreDataKeys.gender: model.gender,
            CoreDataKeys.height: model.height,
            CoreDataKeys.weight: model.weight
        ]

        repository.save(value: value, type: entity) { (response) in
            switch response {
            case .success:
                completion(true)
            case .failure(let error):
                completion(false)
            }
        }
    }

    func changeGoal(to: Int) {

    }
}
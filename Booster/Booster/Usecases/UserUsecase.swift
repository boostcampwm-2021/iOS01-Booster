//
//  UserUsecase.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import Foundation

final class UserUsecase {
    private enum CoreDataKeys {
        static let age = "age"
        static let nickname = "nickname"
        static let gender = "gender"
        static let height = "height"
        static let weight = "weight"
    }

    func eraseAllDataOfHealthKit(completion: @escaping (Result<Int, Error>) -> Void) {
        HealthStoreManager.shared.removeAll { (result) in
            completion(result)
        }
    }

    func eraseAllDataOfCoreData(completion: @escaping (Result<Void, Error>) -> Void) {
        CoreDataManager.shared.delete(entityName: "Tracking") { (result) in
            completion(result)
        }
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

        CoreDataManager.shared.save(attributes: value, type: entity) { (response) in
            switch response {
            case .success:
                completion(true)
            case .failure(let error):
                dump(error)
                completion(false)
            }
        }
    }

    func changeGoal(to: Int) {

    }
}

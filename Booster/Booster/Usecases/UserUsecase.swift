//
//  UserUsecase.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import Foundation
import RxSwift

final class UserUsecase {
    private let disposeBag = DisposeBag()

    func fetchUserInfo() -> Single<UserInfo> {
        return CoreDataManager.shared.fetch()
            .map { [weak self] (value: [User]) in
                var userInfo = UserInfo()

                if let userValue = value.first,
                   let userInfoValue = self?.convertToUserInfoFrom(user: userValue) {
                    userInfo = userInfoValue
                }

                return userInfo
            }
    }

    func removeAllDataOfHealthKit() -> Single<Bool> {
        return HealthKitManager.shared.removeAll()
    }

    func removeAllDataOfCoreData() -> Single<Bool> {
        return Single.create { single in
            let entityName = "Tracking"
            return CoreDataManager.shared.delete(entityName: entityName)
                .subscribe(onSuccess: {
                    single(.success(true))
                }, onFailure: { _ in
                    single(.success(false))
                })
        }
    }

    func editUserInfo(model: UserInfo) -> Single<Bool> {
        return Single.create { single in
            let entityName = "User"
            let value: [String: Any] = [
                CoreDataKeys.age: model.age,
                CoreDataKeys.nickname: model.nickname,
                CoreDataKeys.gender: model.gender,
                CoreDataKeys.height: model.height,
                CoreDataKeys.weight: model.weight
            ]

            return CoreDataManager.shared.update(entityName: entityName, attributes: value)
                .subscribe(onSuccess: {
                    single(.success(true))
                }, onFailure: { error in
                    single(.failure(error))
                })
        }
    }

    func changeGoal(to goal: Int) -> Single<Bool> {
        return Single.create { single in
            let entityName = "User"
            let value: [String: Any] = [
                CoreDataKeys.goal: goal
            ]

            return CoreDataManager.shared.update(entityName: entityName, attributes: value)
                .subscribe(onSuccess: {
                    single(.success(true))
                })
        }
    }

    private func convertToUserInfoFrom(user: User) -> UserInfo? {
        if let nickname = user.nickname,
           let gender = user.gender {
            let userInfo = UserInfo(age: Int(user.age),
                                    nickname: nickname,
                                    gender: gender,
                                    height: Int(user.height),
                                    weight: Int(user.weight),
                                    goal: Int(user.goal))
            return userInfo
        }
        return nil
    }
}

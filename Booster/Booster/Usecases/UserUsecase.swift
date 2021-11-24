//
//  UserUsecase.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import Foundation
import RxSwift

final class UserUsecase {
    private enum CoreDataKeys {
        static let age = "age"
        static let nickname = "nickname"
        static let gender = "gender"
        static let height = "height"
        static let weight = "weight"
        static let goal = "goal"
    }

    private let disposeBag = DisposeBag()

    func fetchUserInfo() -> Observable<UserInfo> {
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

    func removeAllDataOfHealthKit() -> Observable<Bool> {
        return Observable.create { observer in
            HealthStoreManager.shared.removeAll { result in
                switch result {
                case .success:
                    observer.onNext(true)
                case .failure:
                    observer.onNext(false)
                }
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    func removeAllDataOfCoreData() -> Observable<Bool> {
        return Observable.create { observer in
            let entityName = "Tracking"
            CoreDataManager.shared.delete(entityName: entityName) { result in
                switch result {
                case .success:
                    observer.onNext(true)
                case .failure:
                    observer.onNext(false)
                }
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    func editUserInfo(model: UserInfo) -> Observable<Bool> {
        return Observable.create { _ in
            let entityName = "User"
            let value: [String: Any] = [
                CoreDataKeys.age: model.age,
                CoreDataKeys.nickname: model.nickname,
                CoreDataKeys.gender: model.gender,
                CoreDataKeys.height: model.height,
                CoreDataKeys.weight: model.weight
            ]

//            CoreDataManager.shared.save(value: value, type: entityName) { (response) in
//                switch response {
//                case .success:
//                    observer.onNext(true)
//                case .failure:
//                    observer.onNext(false)
//                }
//                observer.onCompleted()
//            }

            return Disposables.create()
        }
    }

    func changeGoal(to goal: Int) -> Observable<Bool> {
        return Observable.create { _ in
            let entityName = "User"
            let value: [String: Any] = [
                CoreDataKeys.goal: goal
            ]
            // TODO: Change To Update
//            CoreDataManager.shared.save(value: value, type: entityName) { (response) in
//                switch response {
//                case .success:
//                    observer.onNext(true)
//                case .failure:
//                    observer.onNext(false)
//                }
//                observer.onCompleted()
//            }

            return Disposables.create()
        }
    }

    private func convertToUserInfoFrom(user: User) -> UserInfo? {
        if let nickname = user.nickname,
           let gender = user.gender {
            let userInfo = UserInfo(age: Int(user.age),
                                    nickname: nickname,
                                    gender: gender,
                                    height: Int(user.height),
                                    weight: Int(user.weight))
            return userInfo
        }
        return nil
    }
}

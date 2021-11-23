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
    }

    private let disposeBag = DisposeBag()

    func eraseAllDataOfHealthKit() -> Observable<Int> {
        return Observable.create { emitter in
            HealthStoreManager.shared.removeAll { result in
                switch result {
                case .success(let count):
                    emitter.onNext(count)
                case .failure(let error):
                    emitter.onError(error)
                }
            }

            return Disposables.create()
        }
    }

    func eraseAllDataOfCoreData() -> Observable<Void> {
        return Observable.create { emitter in
            let entityName = "Tracking"
            CoreDataManager.shared.delete(entityName: entityName) { result in
                switch result {
                case .success:
                    emitter.onNext(())
                case .failure(let error):
                    emitter.onError(error)
                }
            }

            return Disposables.create()
        }
    }

    func editUserInfo(model: UserInfo) -> Observable<Bool> {
        return Observable.create { emitter in
            let entityName = "User"
            let value: [String: Any] = [
                CoreDataKeys.age: model.age,
                CoreDataKeys.nickname: model.nickname,
                CoreDataKeys.gender: model.gender,
                CoreDataKeys.height: model.height,
                CoreDataKeys.weight: model.weight
            ]

            CoreDataManager.shared.save(value: value, type: entityName) { (response) in
                switch response {
                case .success:
                    return emitter.onNext(true)
                case .failure(let error):
                    return emitter.onError(error)
                }
            }

            return Disposables.create()
        }
    }

    func changeGoal(to: Int) {

    }
}

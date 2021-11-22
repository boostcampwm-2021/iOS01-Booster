//
//  EnrollUsecase.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/16.
//

import Foundation
import RxSwift

final class EnrollUsecase {
    private enum CoreDataKeys {
        static let age = "age"
        static let gender = "gender"
        static let height = "height"
        static let nickname = "nickname"
        static let weight = "weight"
        static let goal = "goal"
    }

    private let disposeBag: DisposeBag
    var observable: Observable<Void>

    init() {
        observable = Observable.just(())
        disposeBag = DisposeBag()
    }

    func save(info: UserInfo) -> Observable<Void> {
        let type = "User"
        let value: [String: Any] = [
            CoreDataKeys.age: info.age,
            CoreDataKeys.gender: info.gender,
            CoreDataKeys.height: info.height,
            CoreDataKeys.nickname: info.nickname,
            CoreDataKeys.weight: info.weight,
            CoreDataKeys.goal: info.goal
        ]

        return CoreDataManager.shared.save(value: value, type: type)
    }
}

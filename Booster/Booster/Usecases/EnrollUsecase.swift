//
//  EnrollUsecase.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/16.
//

import Foundation
import RxSwift

class EnrollUsecase {
    var observable: Observable<Void>
    var disposeBag: DisposeBag
    private enum CoreDataKeys {
        static let age = "age"
        static let gender = "gender"
        static let height = "height"
        static let nickName = "nickName"
        static let weight = "weight"
    }

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
            CoreDataKeys.nickName: info.nickName,
            CoreDataKeys.weight: info.weight
        ]

        return CoreDataManager.shared.save(value: value, type: type)
    }
}
//
//  UserViewModel.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import Foundation
import RxSwift

final class UserViewModel {
    enum UserViewModelError: Error {
        case noData
    }

    private let usecase: UserUsecase
    private(set) var model: UserInfo

    init() {
        usecase = UserUsecase()
        model = UserInfo(age: 25, nickname: "히로롱", gender: "여", height: 164, weight: 80)
    }

    func userPhysicalInfo() -> String {
        return "\(model.age)살, \(model.height)cm, \(model.weight)kg, \(model.gender)"
    }

    func eraseAllData() -> Observable<Bool> {
        return Observable.create { [weak self] emitter in
            guard let self = self
            else { return Disposables.create() }

            return Observable.zip(self.usecase.eraseAllDataOfHealthKit(), self.usecase.eraseAllDataOfCoreData())
                .subscribe(onNext: { healthKitResult, coreDataResult in
                    if healthKitResult || coreDataResult {
                        emitter.onNext(true)
                    } else {
                        emitter.onNext(false)
                    }
                    emitter.onCompleted()
                })
        }
    }

    func editUserInfo(gender: String? = nil, age: Int? = nil, height: Int? = nil, weight: Int? = nil, nickname: String? = nil) {
        if let gender = gender { model.gender = gender }
        if let age = age { model.age = age }
        if let height = height { model.height = height }
        if let weight = weight { model.weight = weight }
        if let nickname = nickname { model.nickname = nickname }
    }

    func save() -> Observable<Bool> {
        return Observable.create { [weak self] emitter in
            guard let self = self
            else { return Disposables.create() }

            return self.usecase.editUserInfo(model: self.model)
                .subscribe(onNext: { isSaved in
                    emitter.onNext(isSaved)
                    emitter.onCompleted()
                }, onError: { error in
                    emitter.onError(error)
                })
            }
    }
}

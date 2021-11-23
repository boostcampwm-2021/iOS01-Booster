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
    private let disposeBag = DisposeBag()
    private(set) var model: UserInfo

    init() {
        usecase = UserUsecase()
        model = UserInfo(age: 25, nickname: "히로롱", gender: "여", height: 164, weight: 80)
    }

    func userPhysicalInfo() -> String {
        return "\(model.age)살, \(model.height)cm, \(model.weight)kg, \(model.gender)"
    }

    func eraseAllData() -> Observable<Int> {
        return Observable.create { [weak self] emitter in
            guard let self = self
            else { return Disposables.create() }

            return Observable.zip(self.usecase.eraseAllDataOfHealthKit(), self.usecase.eraseAllDataOfCoreData())
                .debug()
                .subscribe(onNext: { count, _ in
                    emitter.onNext(count)
                    emitter.onCompleted()
                }, onError: { error in
                    emitter.onError(error)
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

    func save(completion: @escaping (Bool) -> Void) {
//        usecase.editUserInfo(model: model) { isSaved in
//            completion(isSaved)
//        }
    }
}

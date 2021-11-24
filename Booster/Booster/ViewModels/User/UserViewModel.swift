//
//  UserViewModel.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import Foundation
import RxSwift
import RxRelay

final class UserViewModel {
    enum UserViewModelError: Error {
        case noData
    }

    private let usecase: UserUsecase
    private let disposeBag = DisposeBag()
    private(set) var model = BehaviorRelay<UserInfo>(value: UserInfo())

    init() {
        usecase = UserUsecase()
        fetchUserInfo()
    }

    func userPhysicalInfo() -> String {
        return "\(model.value.age)살, \(model.value.height)cm, \(model.value.weight)kg, \(model.value.gender)"
    }

    func removeAllData() -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self
            else { return Disposables.create() }

            return Observable.zip(self.usecase.removeAllDataOfHealthKit(), self.usecase.removeAllDataOfCoreData())
                .subscribe(onNext: { healthKitResult, coreDataResult in
                    observer.onNext(healthKitResult || coreDataResult)
                    observer.onCompleted()
                })
        }
    }

    func editUserInfo(gender: String? = nil, age: Int? = nil, height: Int? = nil, weight: Int? = nil, nickname: String? = nil) -> Observable<Bool> {
        var newModel = model.value
        if let gender = gender { newModel.gender = gender }
        if let age = age { newModel.age = age }
        if let height = height { newModel.height = height }
        if let weight = weight { newModel.weight = weight }
        if let nickname = nickname { newModel.nickname = nickname }

        let observableResult = save(model: newModel)
        observableResult
            .subscribe(onNext: { [weak self] isSaved in
                guard let self = self
                else { return }

                if isSaved { self.model.accept(newModel) }
            }).disposed(by: disposeBag)

        return observableResult
    }

    private func fetchUserInfo() {
        usecase.fetchUserInfo()
            .subscribe { [weak self] value in
                guard let self = self,
                      let fetchedModel = value.element
                else { return }

                self.model.accept(fetchedModel)
            }.disposed(by: disposeBag)
    }

    private func save(model: UserInfo) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self
            else { return Disposables.create() }

            return self.usecase.editUserInfo(model: self.model.value)
                .subscribe(onNext: { isSaved in
                    observer.onNext(isSaved)
                    observer.onCompleted()
                }, onError: { error in
                    observer.onError(error)
                })
            }
    }
}

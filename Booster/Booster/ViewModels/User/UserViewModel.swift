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

    private let usecase = UserUsecase()
    private let disposeBag = DisposeBag()
    private(set) var model = BehaviorRelay<UserInfo>(value: UserInfo())
    private(set) var isEditingComplete = PublishRelay<Bool>()
    
    init() {
        fetchUserInfo()
    }

    func userPhysicalInfo() -> String {
        return "\(model.value.age)살, \(model.value.height)cm, \(model.value.weight)kg, \(model.value.gender)"
    }

    func removeAllData() -> Single<Bool> {
        return Single.create { [weak self] single in
            guard let self = self
            else { return Disposables.create() }

            return Single.zip(self.usecase.removeAllDataOfHealthKit(), self.usecase.removeAllDataOfCoreData())
                .subscribe { healthKitResult, coreDataResult in
                    single(.success(healthKitResult || coreDataResult))
                }
        }
    }

    func editUserInfo(gender: String? = nil, age: Int? = nil, height: Int? = nil, weight: Int? = nil, nickname: String? = nil) {
        var newModel = model.value
        if let gender = gender { newModel.gender = gender }
        if let age = age { newModel.age = age }
        if let height = height { newModel.height = height }
        if let weight = weight { newModel.weight = weight }
        if let nickname = nickname { newModel.nickname = nickname }

        self.usecase.editUserInfo(model: newModel)
            .subscribe { [weak self] result in
                switch result {
                case .success:
                    self?.model.accept(newModel)
                    self?.isEditingComplete.accept(true)
                case .failure:
                    self?.isEditingComplete.accept(false)
                }
            }.disposed(by: disposeBag)
    }

    func changeGoal(to goal: Int) -> Single<Bool> {
        var newModel = model.value
        newModel.goal = goal
        return Single.create { [weak self] single in
            guard let self = self
            else { return Disposables.create() }

            return self.usecase.changeGoal(to: goal)
                .subscribe(onSuccess: { [weak self] _ in
                    self?.model.accept(newModel)
                    single(.success(true))
                })
        }
    }

    private func fetchUserInfo() {
        usecase.fetchUserInfo()
            .subscribe(onSuccess: { [weak self] userInfo in
                self?.model.accept(userInfo)
            }).disposed(by: disposeBag)
    }
}

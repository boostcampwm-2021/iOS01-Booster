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

    func editUserInfo(gender: String? = nil, age: Int? = nil, height: Int? = nil, weight: Int? = nil, nickname: String? = nil) {
        var newModel = model.value
        if let gender = gender { newModel.gender = gender }
        if let age = age { newModel.age = age }
        if let height = height { newModel.height = height }
        if let weight = weight { newModel.weight = weight }
        if let nickname = nickname { newModel.nickname = nickname }

        self.usecase.editUserInfo(model: newModel)
            .take(1)
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.model.accept(newModel)
                    self?.isEditingComplete.accept(true)
                } else {
                    self?.isEditingComplete.accept(false)
                }
            }, onError: { [weak self] _ in
                self?.isEditingComplete.accept(false)
            }).disposed(by: disposeBag)
    }

    func changeGoal(to goal: Int) -> Observable<Bool> {
        var newModel = model.value
        newModel.goal = goal
        return Observable.create { [weak self] observer in
            guard let self = self
            else { return Disposables.create() }

            return self.usecase.changeGoal(to: goal)
                .take(1)
                .subscribe(onNext: { result in
                    if result {
                        self.model.accept(newModel)
                        observer.onNext(true)
                    } else {
                        observer.onNext(false)
                    }
                    observer.onCompleted()
                }, onError: { (_) in
                    observer.onNext(false)
                })
        }
    }

    private func fetchUserInfo() {
        usecase.fetchUserInfo()
            .subscribe { [weak self] result in
                guard let self = self,
                      let fetchedModel = result.element
                else { return }

                self.model.accept(fetchedModel)
            }.disposed(by: disposeBag)
    }
}

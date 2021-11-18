//
//  EnrollViewModel.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/16.
//

import Foundation
import RxSwift
import RxCocoa

final class EnrollViewModel {
    private let usecase = EnrollUsecase()
    private let disposeBag = DisposeBag()
    private var userinfo = BehaviorRelay<UserInfo>(value: UserInfo())
    let age = PublishSubject<Int>()
    let nickName = PublishSubject<String>()
    let height = PublishSubject<Int>()
    let weight = PublishSubject<Int>()
    let step = PublishSubject<Int>()
    let gender = PublishSubject<Bool>()
    var save = PublishSubject<Bool>()

    init() {
        stepBind()
        inputBind()
    }

    private func stepBind() {
        step.filter { $0 > 5 }
            .subscribe { [weak self] _ in
                guard let self = self
                else { return }
                self.usecase.save(info: self.userinfo.value)
                    .subscribe(onNext: {
                        self.save.onNext(true)
                    }, onError: { _ in
                        self.save.onNext(false)
                    }).disposed(by: self.disposeBag)
            }.disposed(by: disposeBag)
    }

    private func inputBind() {
        age.bind { [weak self] value in
            guard let self = self
            else { return }

            var info = self.userinfo.value
            info.age = value
            self.userinfo.accept(info)
        }.disposed(by: disposeBag)

        weight.bind { [weak self] value in
            guard let self = self
            else { return }

            var info = self.userinfo.value
            info.weight = value
            self.userinfo.accept(info)
        }.disposed(by: disposeBag)

        height.bind { [weak self] value in
            guard let self = self
            else { return }

            var info = self.userinfo.value
            info.height = value
            self.userinfo.accept(info)
        }.disposed(by: disposeBag)

        nickName.bind { [weak self] value in
            guard let self = self
            else { return }

            var info = self.userinfo.value
            info.nickname = value
            self.userinfo.accept(info)
        }.disposed(by: disposeBag)

        gender.bind { [weak self] value in
            guard let self = self
            else { return }

            var info = self.userinfo.value
            info.gender = value ? "여" : "남"
            self.userinfo.accept(info)
            self.step.onNext(2)
        }.disposed(by: disposeBag)
    }
}

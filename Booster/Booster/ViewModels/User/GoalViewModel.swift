//
//  GoalViewModel.swift
//  Booster
//
//  Created by mong on 2021/11/17.
//

import Foundation
import RxSwift
import RxRelay

final class GoalViewModel {
    private(set) var model = BehaviorRelay<UserInfo>(value: UserInfo())
    private let usecase: UserUsecase
    private let disposeBag = DisposeBag()

    init() {
        usecase = UserUsecase()
    }

    func fetchUserInfo() {
//        usecase.fetchUserInfo()
//            .subscribe(onNext: { [weak self] userInfo in
//                self?.model.accept(userInfo)
//                print(userInfo)
//            }).disposed(by: disposeBag)
    }
}

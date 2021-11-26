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
    private let usecase = UserUsecase()
    private let disposeBag = DisposeBag()

    init() {

    }
}

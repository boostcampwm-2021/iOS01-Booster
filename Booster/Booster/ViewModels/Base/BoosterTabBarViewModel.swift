//
//  BoosterTabBarViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/30.
//

import Foundation
import RxSwift

final class BoosterTabBarViewModel {
    //MARK: - Properties
    private let usecase = BoosterTabBarUsecase()
    
    //MARK: - Functions
    func requestHealthKitAccess() {
        usecase.configureHealthKit()
    }
}

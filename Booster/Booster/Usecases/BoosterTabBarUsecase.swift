//
//  BoosterTabBarUsecase.swift
//  Booster
//
//  Created by hiju on 2021/11/30.
//

import Foundation
import HealthKit
import RxSwift

protocol BoosterTabBarUsecaseProtocol {
    func configureHealthKit()
}

final class BoosterTabBarUsecase: BoosterTabBarUsecaseProtocol {
    private let disposeBag = DisposeBag()
    
    func configureHealthKit() {
        guard let activeEnergyBurned = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
              let distanceWalkingRunning = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
              let stepCount = HKSampleType.quantityType(forIdentifier: .stepCount)
        else { return }

        let shareTypes = Set([activeEnergyBurned, distanceWalkingRunning, stepCount])
        let readTypes = Set([activeEnergyBurned, distanceWalkingRunning, stepCount])

        HealthKitManager.shared.requestAuthorization(shareTypes: shareTypes, readTypes: readTypes)
            .subscribe { _ in }
            .disposed(by: disposeBag)
    }
}

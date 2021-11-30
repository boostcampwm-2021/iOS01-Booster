//
//  HomeViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/01.
//
import Foundation
import HealthKit

import RxSwift
import RxRelay

final class HomeViewModel {
    // MARK: - Properties
    private let homeUsecase = HomeUsecase()
    private let disposeBag = DisposeBag()

    var homeModel = BehaviorRelay<HomeModel>(value: HomeModel())

    // MARK: - Functions
    func fetchQueries() {
        fetchTodayHourlyStepCountsData()
        fetchTodayDistanceData()
        fetchTodayKcalData()
        fetchTodayTotalStepCountsData()
        fetchGoalData()
    }
    
    func sendGoalNotification() {
        let boosterUserNotification = BoosterUserNotification()
        boosterUserNotification.setNotification(requestType: .add, type: .goal)
    }

    private func fetchTodayHourlyStepCountsData() {
        homeUsecase.fetchHourlyStepCountsData()
            .subscribe { [weak self] stepStatisticsCollection in
                guard let self = self,
                      case let .success(stepStatisticsCollection) = stepStatisticsCollection
                else { return }

                var newHomeModel = self.homeModel.value
                newHomeModel.hourlyStatistics = stepStatisticsCollection
                self.homeModel.accept(newHomeModel)
            }
            .disposed(by: disposeBag)
    }

    private func fetchTodayDistanceData() {
        homeUsecase.fetchTodayTotalData(type: .distanceWalkingRunning)
            .subscribe { [weak self] hkStatistics in
                guard let self = self,
                      case let .success(hkStatistics) = hkStatistics
                else { return }

                let distance = hkStatistics?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                let km = distance / 1000

                var newHomeModel = self.homeModel.value
                newHomeModel.km = km
                self.homeModel.accept(newHomeModel)
            }
            .disposed(by: disposeBag)
    }

    private func fetchTodayKcalData() {
        homeUsecase.fetchTodayTotalData(type: .activeEnergyBurned)
            .subscribe {[weak self] hkStatistics in
                guard let self = self,
                      case let .success(hkStatistics) = hkStatistics
                else { return }

                let kcal = hkStatistics?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0

                var newHomeModel = self.homeModel.value
                newHomeModel.kcal = Int(kcal)
                self.homeModel.accept(newHomeModel)
            }
            .disposed(by: disposeBag)
    }

    private func fetchTodayTotalStepCountsData() {
        homeUsecase.fetchTodayTotalData(type: .stepCount)
            .subscribe { [weak self] hkStatistics in
                guard let self = self,
                      case let .success(hkStatistics) = hkStatistics
                else { return }

                let time = hkStatistics?.duration()?.doubleValue(for: .second()) ?? 0
                let sum = hkStatistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0

                var newHomeModel = self.homeModel.value
                newHomeModel.activeTime = TimeInterval(time)
                newHomeModel.totalStepCount = Int(sum)

                self.homeModel.accept(newHomeModel)
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchGoalData() {
        homeUsecase.fetchGoalData()
            .subscribe { [weak self] goal in
                guard let self = self,
                      case let .success(goal) = goal
                else { return }
                
                var newHomeModel = self.homeModel.value
                newHomeModel.goal = goal ?? 10000
                
                self.homeModel.accept(newHomeModel)
            }
            .disposed(by: disposeBag)
    }
}

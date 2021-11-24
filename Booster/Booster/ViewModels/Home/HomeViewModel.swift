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
    }

    private func fetchTodayHourlyStepCountsData() {
        homeUsecase.fetchHourlyStepCountsData()
            .subscribe { [weak self] hkStatisticsEvent in
                guard let self = self,
                      let hkStatistics = hkStatisticsEvent.element,
                      let entity = self.configureStepStatistics(using: hkStatistics)
                else { return }

                var newHomeModel = self.homeModel.value
                newHomeModel.hourlyStatistics.append(entity)
                self.homeModel.accept(newHomeModel)
            }
            .disposed(by: disposeBag)
    }

    private func fetchTodayDistanceData() {
        homeUsecase.fetchTodayTotalData(type: .distanceWalkingRunning)
            .subscribe { [weak self] result in
                guard let self = self,
                      let statistics = result.element
                else { return }

                let distance = statistics.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                let km = distance / 1000

                var newHomeModel = self.homeModel.value
                newHomeModel.km = km
                self.homeModel.accept(newHomeModel)
            }
            .disposed(by: disposeBag)
    }

    private func fetchTodayKcalData() {
        homeUsecase.fetchTodayTotalData(type: .activeEnergyBurned)
            .subscribe {[weak self] result in
                guard let self = self,
                      let statistics = result.element
                else { return }

                let kcal = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0

                var newHomeModel = self.homeModel.value
                newHomeModel.kcal = Int(kcal)
                self.homeModel.accept(newHomeModel)

            }
            .disposed(by: disposeBag)
    }

    private func fetchTodayTotalStepCountsData() {
        homeUsecase.fetchTodayTotalData(type: .stepCount)
            .subscribe { [weak self] result in
                guard let self = self,
                      let statistics = result.element,
                      let seconds = statistics.duration()?.doubleValue(for: .second()),
                      let sum = statistics.sumQuantity()?.doubleValue(for: .count())
                else { return }

                var newHomeModel = self.homeModel.value
                newHomeModel.activeTime = TimeInterval(seconds)
                newHomeModel.totalStepCount = Int(sum)
                self.homeModel.accept(newHomeModel)

            }
            .disposed(by: disposeBag)
    }

    private func configureStepStatistics(using statistics: HKStatistics) -> StepStatistics? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "H"

        let step = Int(statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
        let date = statistics.startDate
        let string = dateFormatter.string(from: date)

        return StepStatistics(step: step, abbreviatedDateString: string)
    }
}

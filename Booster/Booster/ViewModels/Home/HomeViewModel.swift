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
    var homeModel = BehaviorRelay<HomeModel>(value: HomeModel())
    private let homeUsecase: HomeUsecase
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init() { self.homeUsecase = HomeUsecase() }

    // MARK: - Functions
    func fetchQueries() {
        fetchTodayHourlyStepCountsData()
        fetchTodayDistanceData()
        fetchTodayKcalData()
        fetchTodayTotalStepCountsData()
    }

    private func fetchTodayHourlyStepCountsData() {
        homeUsecase.fetchHourlyStepCountsData()
            .subscribe { [weak self] result in
                guard let statistics = result.element,
                      let entity = self?.convertHkStatisticsToCustomStatisticsOfStepCount(statistics)
                else { return }

                guard var newHomeModel = self?.homeModel.value
                else { return }
                newHomeModel.hourlyStatistics.append(statistics: entity)
                self?.homeModel.accept(newHomeModel)
            }
            .disposed(by: disposeBag)
    }

    private func fetchTodayDistanceData() {
        homeUsecase.fetchTodayTotalData(type: .distanceWalkingRunning)
            .subscribe { [weak self] result in
                guard let statistics = result.element
                else { return }

                let distance = statistics.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                let km = distance / 1000

                guard var newHomeModel = self?.homeModel.value
                else { return }
                newHomeModel.km = km
                self?.homeModel.accept(newHomeModel)
            }
            .disposed(by: disposeBag)
    }

    private func fetchTodayKcalData() {
        homeUsecase.fetchTodayTotalData(type: .activeEnergyBurned)
            .subscribe {[weak self] result in
                guard let statistics = result.element
                else { return }

                let kcal = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0

                guard var newHomeModel = self?.homeModel.value
                else { return }
                newHomeModel.kcal = Int(kcal)
                self?.homeModel.accept(newHomeModel)

            }
            .disposed(by: disposeBag)
    }

    private func fetchTodayTotalStepCountsData() {
        homeUsecase.fetchTodayTotalData(type: .stepCount)
            .subscribe { [weak self] result in
                guard let statistics = result.element,
                      let seconds = statistics.duration()?.doubleValue(for: .second()),
                      let sum = statistics.sumQuantity()?.doubleValue(for: .count())
                else { return }

                guard var newHomeModel = self?.homeModel.value
                else { return }
                newHomeModel.activeTime = TimeInterval(seconds)
                newHomeModel.totalStepCount = Int(sum)
                self?.homeModel.accept(newHomeModel)

            }
            .disposed(by: disposeBag)
    }

    private func addEmptyStatisticsIfNeeded(nowDate: Date) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "hh"

        var newHomeModel = homeModel.value
        guard let lastStatisticsDate = homeModel.value.hourlyStatistics.statistics().last
        else {
            let nowHour = Int(dateformatter.string(from: nowDate)) ?? 0
            for _ in 0..<nowHour {
                newHomeModel.hourlyStatistics.append(statistics: Statistics(date: Date(), step: 0))
            }
            homeModel.accept(newHomeModel)
            return
        }

        let preHour = Int(dateformatter.string(from: lastStatisticsDate.date)) ?? 0
        let nowHour = Int(dateformatter.string(from: nowDate)) ?? 0

        var interval = nowHour - preHour
        if interval < 0 { interval += 12 }
        if interval > 1 {
            for _ in 0..<interval - 1 {
                newHomeModel.hourlyStatistics.append(statistics: Statistics(date: Date(), step: 0))
            }
        }
        homeModel.accept(newHomeModel)
    }

    private func convertHkStatisticsToCustomStatisticsOfStepCount(_ statistics: HKStatistics) -> Statistics? {
        guard let quantity = statistics.sumQuantity()
        else { return nil }
        let step = Int(quantity.doubleValue(for: HKUnit.count()))
        let date = statistics.startDate
        addEmptyStatisticsIfNeeded(nowDate: date)
        return Statistics(date: date, step: step)
    }
}

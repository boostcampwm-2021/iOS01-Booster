//
//  HomeViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/01.
//
import Foundation
import HealthKit

final class HomeViewModel {
    // MARK: - Properties
    var homeModel: Observable<HomeModel> = Observable(HomeModel())

    private let homeUsecase: HomeUsecase

    // MARK: - Init
    init() { self.homeUsecase = HomeUsecase() }

    // MARK: - Functions
    func fetchQueries() {
        self.fetchTodayHourlyStepCountsData()
        self.fetchTodayDistanceData()
        self.fetchTodayKcalData()
        self.fetchTodayTotalStepCountsData()
    }

    private func fetchTodayHourlyStepCountsData() {
        homeUsecase.fetchHourlyStepCountsData { [weak self] statistics in
            if let quantity = statistics.sumQuantity() {
                let step = Int(quantity.doubleValue(for: HKUnit.count()))
                let date = statistics.startDate
                self?.addEmptyStatisticsIfNeeded(nowDate: date)
                let entity = Statistics(date: date, step: step)
                self?.homeModel.value.hourlyStatistics.append(statistics: entity)
            }
        }
    }

    private func fetchTodayDistanceData() {
        homeUsecase.fetchTodayTotalData(type: .distanceWalkingRunning) { [weak self] result in
            let distance = result.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
            let km = distance / 1000
            self?.homeModel.value.km = km
        }
    }

    private func fetchTodayKcalData() {
        homeUsecase.fetchTodayTotalData(type: .activeEnergyBurned) { [weak self] result in
            let kcal = result.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            self?.homeModel.value.kcal = Int(kcal)
        }
    }

    private func fetchTodayTotalStepCountsData() {
        homeUsecase.fetchTodayTotalData(type: .stepCount) { [weak self] result in
            guard let seconds = result.duration()?.doubleValue(for: .second()),
                  let sum = result.sumQuantity()?.doubleValue(for: .count())
            else { return }

            self?.homeModel.value.activeTime = TimeInterval(seconds)
            self?.homeModel.value.totalStepCount = Int(sum)
        }
    }

    private func addEmptyStatisticsIfNeeded(nowDate: Date) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "hh"

        guard let lastStatisticsDate = homeModel.value.hourlyStatistics.statistics().last
        else {
            let nowHour = Int(dateformatter.string(from: nowDate)) ?? 0
            for _ in 0..<nowHour {
                homeModel.value.hourlyStatistics.append(statistics: Statistics(date: Date(), step: 0))
            }
            return
        }

        let preHour = Int(dateformatter.string(from: lastStatisticsDate.date)) ?? 0
        let nowHour = Int(dateformatter.string(from: nowDate)) ?? 0

        var interval = nowHour - preHour
        if interval < 0 { interval += 12 }
        if interval > 1 {
            for _ in 0..<interval - 1 {
                homeModel.value.hourlyStatistics.append(statistics: Statistics(date: Date(), step: 0))
            }
        }
    }
}

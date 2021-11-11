//
//  HomeViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/01.
//
import Foundation
import HealthKit

final class HomeViewModel {
    var homeData: Observable<HomeData> = Observable(HomeData())

    init() { }

    func fetchQueries() {
        self.fetchTotalStepCountsData()
        self.fetchHourlyStepCountsData()
        self.fetchDistanceData()
        self.fetchKcalData()
    }

    private func fetchHourlyStepCountsData() {
        homeData.value.hourlyStepCount = []
        guard let stepCountSampleType = HKSampleType.quantityType(forIdentifier: .stepCount),
              let anchorDate = Calendar.current.date(bySettingHour: 12,
                                                     minute: 0,
                                                     second: 0,
                                                     of: Date())
        else { return }

        let now = Date()
        let predicate = createTodayPredicate()

        HealthStoreManager.shared.requestStatisticsCollectionQuery(type: stepCountSampleType,
                                                                   predicate: predicate,
                                                                   interval: DateComponents(hour: 1),
                                                                   anchorDate: anchorDate) { [weak self] result in
            result.enumerateStatistics(from: self?.retrieveTodayStartDate(from: now) ?? now,
                                       to: now,
                                       with: { [weak self] result, _ in
                    let totalStepForHour = result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    self?.homeData.value.hourlyStepCount.append(Int(totalStepForHour))
                }
            )
        }
    }

    private func fetchDistanceData() {
        guard let distanceSampleType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
              let anchorDate = Calendar.current.date(bySettingHour: 12,
                                                minute: 0,
                                                second: 0,
                                                of: Date())
        else { return }

        let now = Date()
        let predicate = createTodayPredicate()

        HealthStoreManager.shared.requestStatisticsCollectionQuery(type: distanceSampleType,
                                                                   predicate: predicate,
                                                                   interval: DateComponents(hour: 1),
                                                                   anchorDate: anchorDate) { [weak self] result in
            result.enumerateStatistics(from: self?.retrieveTodayStartDate(from: now) ?? now,
                                       to: now,
                                       with: { [weak self] result, _ in
                    let distance = result.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                    let meter = round(distance * 100) / 100
                    let km = meter / 1000
                    self?.homeData.value.km += km
                }
            )
        }
    }

    private func fetchKcalData() {
        guard let kcalSampleType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
              let anchorDate = Calendar.current.date(bySettingHour: 12,
                                                minute: 0,
                                                second: 0,
                                                of: Date())
        else { return }

        let now = Date()
        let predicate = createTodayPredicate()

        HealthStoreManager.shared.requestStatisticsCollectionQuery(type: kcalSampleType,
                                                                   predicate: predicate,
                                                                   interval: DateComponents(hour: 1),
                                                                   anchorDate: anchorDate) { [weak self] result in
            result.enumerateStatistics(from: self?.retrieveTodayStartDate(from: now) ?? now,
                                       to: now,
                                       with: { [weak self] result, _ in
                    let kcal = result.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                    self?.homeData.value.kcal += Int(kcal)
                }
            )
        }
    }

    private func fetchTotalStepCountsData() {
        guard let totalStepSampleType = HKSampleType.quantityType(forIdentifier: .stepCount)
        else { return }

        let now = Date()
        let start = retrieveTodayStartDate(from: now)
        let predicate = HKQuery.predicateForSamples(withStart: start,
                                                    end: now,
                                                    options: .strictStartDate)

        HealthStoreManager.shared.requestStatisticsQuery(type: totalStepSampleType, predicate: predicate) { [weak self] result in
            guard let seconds = result.duration()?.doubleValue(for: .second()),
                  let sum = result.sumQuantity()?.doubleValue(for: .count()) else { return }
            self?.homeData.value.activeTime = TimeInterval(seconds)
            self?.homeData.value.totalStepCount = Int(sum)
        }
    }

    private func createTodayPredicate(end: Date = Date()) -> NSPredicate {
        return HKQuery.predicateForSamples(withStart: retrieveTodayStartDate(from: end),
                                           end: end,
                                           options: .strictStartDate)
    }

    private func retrieveTodayStartDate(from date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
}

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

    private var healthStore: HKHealthStore?

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
         let anchorDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) else { return }

        let now = Date()
        let predicate = createTodayPredicate()

        HealthStoreManager.shared.requestStatisticsCollectionQuery(type: stepCountSampleType, predicate: predicate, interval: DateComponents(hour: 1), anchorDate: anchorDate) { [weak self] result in
            result.enumerateStatistics(
                from: self?.retrieveTodayStartDate(from: now) ?? now,
                to: now,
                with: { [weak self] (result, _) in
                    let totalStepForHour = result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    self?.homeData.value.hourlyStepCount.append(Int(totalStepForHour))
                }
            )
        }
    }

    private func fetchDistanceData() {
        guard let distanceSampleType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
         let anchorDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) else { return }

        let now = Date()
        let predicate = createTodayPredicate()

        HealthStoreManager.shared.requestStatisticsCollectionQuery(type: distanceSampleType, predicate: predicate, interval: DateComponents(hour: 1), anchorDate: anchorDate) { [weak self] result in
            result.enumerateStatistics(
                from: self?.retrieveTodayStartDate(from: now) ?? now,
                to: now,
                with: { [weak self] result, _ in
                    let distance = floor(result.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0)
                    self?.homeData.value.km += distance / 1000
                }
            )
        }
    }

    private func fetchKcalData() {
        guard let kcalSampleType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
         let anchorDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) else { return }

        let now = Date()
        let predicate = createTodayPredicate()

        HealthStoreManager.shared.requestStatisticsCollectionQuery(type: kcalSampleType, predicate: predicate, interval: DateComponents(hour: 1), anchorDate: anchorDate) { [weak self] result in
            result.enumerateStatistics(
                from: self?.retrieveTodayStartDate(from: now) ?? now,
                to: now,
                with: { [weak self] result, _ in
                    let kcal = result.sumQuantity()?.doubleValue(for: HKUnit.smallCalorie()) ?? 0
                    self?.homeData.value.kcal += Int(kcal)
                }
            )
        }
    }

    private func fetchTotalStepCountsData() {
        guard let totalStepSampleType = HKSampleType.quantityType(forIdentifier: .stepCount) else { return }
        let end = Date()
        let start = retrieveTodayStartDate(from: end)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        HealthStoreManager.shared.requestStatisticsQuery(type: totalStepSampleType, predicate: predicate) { result in
            guard let seconds = result.duration()?.doubleValue(for: .second()),
             let sum = result.sumQuantity()?.doubleValue(for: .count()) else { return }
            self.homeData.value.activeTime = TimeInterval(seconds)
            self.homeData.value.totalStepCount = Int(sum)
        }
    }

    private func createTodayPredicate(end: Date = Date()) -> NSPredicate {
        let predicate = HKQuery.predicateForSamples(
            withStart: retrieveTodayStartDate(from: end),
            end: end,
            options: .strictStartDate
        )
        return predicate
    }

    private func retrieveTodayStartDate(from date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

}

final class Observable<T> {

    private var listener: ((T) -> Void)?

    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }

}

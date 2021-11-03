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

    init() { configureHealthKit() }

    private func configureHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()

            guard let activeEnergyBurnedQuantityType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
                  let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
                  let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)
            else {
                return
            }

            let allTypes = Set([activeEnergyBurnedQuantityType, distanceWalkingRunning, stepCount])

            healthStore?.requestAuthorization(toShare: allTypes, read: allTypes) { (success, _) in
                if !success {
                    print("it is bad access")
                    // need error alert
                    return
                }
                self.fetchTotalStepCountsData()
                self.fetchHourlyStepCountsData()
                self.fetchDistanceData()
                self.fetchKcalData()
            }
        }
    }

    private func fetchHourlyStepCountsData() {
        homeData.value.hourlyStepCount = []
        guard let stepCountSampleType = HKSampleType.quantityType(forIdentifier: .stepCount) else { return }

        let now = Date()
        let predicate = createTodayPredicate()

        guard let query = createTodayQuantityQuery(type: stepCountSampleType, predicate: predicate, interval: DateComponents(hour: 1)) else { return }

        query.initialResultsHandler = { [weak self] _, results, _ in
            guard let results = results else { return }

            results.enumerateStatistics(
                from: self?.retrieveTodayStartDate(from: now) ?? now,
                to: now,
                with: { [weak self] (result, _) in
                    let totalStepForHour = result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    self?.homeData.value.hourlyStepCount.append(Int(totalStepForHour))
                }
            )
        }

        healthStore?.execute(query)
    }

    private func fetchDistanceData() {
        guard let distanceSampleType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }

        let now = Date()
        let predicate = createTodayPredicate()

        guard let query = createTodayQuantityQuery(type: distanceSampleType, predicate: predicate, interval: DateComponents(day: 1)) else { return }

        query.initialResultsHandler = { [weak self] _, results, _ in
            guard let results = results else { return }

            results.enumerateStatistics(
                from: self?.retrieveTodayStartDate(from: now) ?? now,
                to: now,
                with: { (result, _) in
                    let distance = floor(result.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0)
                    self?.homeData.value.km += distance / 1000
                }
            )
        }

        healthStore?.execute(query)
    }

    private func fetchKcalData() {
        guard let stepCountSampleType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let now = Date()
        let predicate = createTodayPredicate()

        guard let query = createTodayQuantityQuery(type: stepCountSampleType, predicate: predicate, interval: DateComponents(day: 1)) else { return }

        query.initialResultsHandler = { [weak self] _, results, _ in
            guard let results = results else { return }

            results.enumerateStatistics(
                from: self?.retrieveTodayStartDate(from: now) ?? now,
                to: now,
                with: { (result, _) in
                    let kcal = result.sumQuantity()?.doubleValue(for: HKUnit.smallCalorie()) ?? 0
                    self?.homeData.value.kcal += Int(kcal)
                }
            )
        }

        healthStore?.execute(query)
    }

    private func fetchTotalStepCountsData() {
        guard let timeSampleType = HKSampleType.quantityType(forIdentifier: .stepCount) else { return }
        let end = Date()
        let start = retrieveTodayStartDate(from: end)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        var totalStepCount = 0.0
        var totalTime = 0.0

        let stepQuery = HKSampleQuery(sampleType: timeSampleType, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) { [weak self] (_, result, error) -> Void in
            if error != nil { return }

            if let result = result as? [HKQuantitySample] {
                for tmp in result {
                    totalStepCount += tmp.quantity.doubleValue(for: .count())
                    totalTime += tmp.endDate.timeIntervalSince(tmp.startDate)
                }
                self?.homeData.value.totalStepCount = Int(totalStepCount)
                self?.homeData.value.activeTime = totalTime
            }
        }
        healthStore?.execute(stepQuery)
    }

    private func createTodayPredicate(end: Date = Date()) -> NSPredicate {
        let predicate = HKQuery.predicateForSamples(
            withStart: retrieveTodayStartDate(from: end),
            end: end,
            options: .strictStartDate
        )
        return predicate
    }

    private func createTodayQuantityQuery(type: HKQuantityType, predicate: NSPredicate, interval: DateComponents) -> HKStatisticsCollectionQuery? {
        let calendar = Calendar.current
        guard let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) else { return nil }

        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        return query
    }

    private func retrieveTodayStartDate(from date: Date = Date()) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

}

struct HomeData {
    var kcal: Int
    var km: Double
    var activeTime: TimeInterval
    var goal: Int
    var totalStepCount: Int
    var hourlyStepCount: [Int] = []

    init() {
        kcal = 0
        km = 0.0
        activeTime = 0
        goal = 0
        totalStepCount = 0
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

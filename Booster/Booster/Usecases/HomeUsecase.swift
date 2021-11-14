//
//  HomeUsecase.swift
//  Booster
//
//  Created by hiju on 2021/11/14.
//
import Foundation
import HealthKit

final class HomeUsecase {
    func fetchHourlyStepCountsData(completion: @escaping (HKStatistics) -> Void) {
        guard let stepCountSampleType = HKSampleType.quantityType(forIdentifier: .stepCount),
              let anchorDate = Calendar.current.date(bySettingHour: 0,
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
                                       with: { statistics, _ in
                completion(statistics)
            })
        }
    }

    func fetchTodayTotalData(type: HKQuantityTypeIdentifier, completion: @escaping (HKStatistics) -> Void) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: type)
        else { return }

        let now = Date()
        let start = retrieveTodayStartDate(from: now)
        let predicate = HKQuery.predicateForSamples(withStart: start,
                                                    end: now,
                                                    options: .strictStartDate)

        HealthStoreManager.shared.requestStatisticsQuery(type: sampleType, predicate: predicate) { result in
            completion(result)
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

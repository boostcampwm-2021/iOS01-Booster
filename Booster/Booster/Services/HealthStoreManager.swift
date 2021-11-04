//
//  HealthStoreManager.swift
//  Booster
//
//  Created by Hani on 2021/11/04.
//

import Foundation
import HealthKit

final class HealthStoreManager {

    static let shared = HealthStoreManager()

    private var healthStore: HKHealthStore?

    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()

        } else {
            return
        }
    }

    func requestAuthorization(shareTypes: Set<HKSampleType>, readTypes: Set<HKSampleType>, completion: @escaping (Bool) -> Void) {
        healthStore?.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
            guard error != nil,
                  success else { return }
            completion(success)
        }
    }

    func requestStatisticsCollectionQuery(type: HKQuantityType, predicate: NSPredicate, interval: DateComponents, anchorDate: Date, completion: @escaping (HKStatisticsCollection) -> Void) {
        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: interval
        )

        query.initialResultsHandler = { _, hkStatisticsCollection, _ in
            if let hkStatisticsCollection = hkStatisticsCollection {
                completion(hkStatisticsCollection)
            }
        }

        healthStore?.execute(query)
    }

    func requestStatisticsQuery(type: HKQuantityType, predicate: NSPredicate, completion: @escaping (HKStatistics) -> Void) {
        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: [.cumulativeSum, .duration]) { _, statistics, _ in
            if let statistics = statistics {
                completion(statistics)
            }
        }

        healthStore?.execute(query)
    }

}

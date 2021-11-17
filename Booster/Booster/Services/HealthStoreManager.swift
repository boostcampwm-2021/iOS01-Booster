//
//  HealthStoreManager.swift
//  Booster
//
//  Created by Hani on 2021/11/04.
//

import Foundation
import HealthKit

typealias HealthQuantityType = HealthStoreManager.HealthQuantityType
typealias HealthUnit = HealthStoreManager.HealthUnit

final class HealthStoreManager {
    enum HealthQuantityType: CaseIterable {
        case steps, runing, energy

        var quantity: HKQuantityType? {
            switch self {
            case .steps: return .quantityType(forIdentifier: .stepCount)
            case .runing: return .quantityType(forIdentifier: .distanceWalkingRunning)
            case .energy: return .quantityType(forIdentifier: .activeEnergyBurned)
            }
        }
    }

    enum HealthUnit: CaseIterable {
        case count, kilometer, calorie
        var unit: HKUnit {
            switch self {
            case .count: return .count()
            case .kilometer: return .meterUnit(with: .kilo)
            case .calorie: return .kilocalorie()
            }
        }
    }

    enum HealthKitError: Error {
        case optionalCasting
        case removeAllDataFail
    }

    static let shared = HealthStoreManager()

    private let metadataKey = "Booster"
    private let metadataVersion = 1
    private var healthStore: HKHealthStore?

    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()

        } else {
            return
        }
    }

    func requestAuthorization(shareTypes: Set<HKSampleType>,
                              readTypes: Set<HKSampleType>,
                              completion: @escaping (Bool) -> Void) {
        healthStore?.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
            guard error == nil,
                  success
            else { return }
            completion(success)
        }
    }

    func requestStatisticsCollectionQuery(type: HKQuantityType,
                                          predicate: NSPredicate,
                                          interval: DateComponents,
                                          anchorDate: Date,
                                          completion: @escaping (HKStatisticsCollection) -> Void) {
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

    func requestStatisticsQuery(type: HKQuantityType,
                                predicate: NSPredicate,
                                completion: @escaping (HKStatistics) -> Void) {
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

    func save(count: Double,
              start: Date,
              end: Date,
              quantity: HealthQuantityType,
              unit: HealthUnit,
              completion: @escaping (Error?) -> Void) {
        guard let healthStore = healthStore,
                let type = quantity.quantity
        else {
            completion(HealthKitError.optionalCasting)
            return
        }

        let unit = unit.unit
        let countQuantity = HKQuantity(unit: unit, doubleValue: count)
        let sample = HKQuantitySample(type: type,
                                      quantity: countQuantity,
                                      start: start,
                                      end: end)

        healthStore.save(sample) { _, error in
            guard let error = error
            else {
                completion(nil)
                return
            }
            completion(error)
        }
    }

    func removeAll(completion: @escaping (Result<Int, Error>) -> Void) {
        var removedCount = 0

        guard let healthStore = healthStore
        else {
            completion(.failure(HealthKitError.optionalCasting))
            return
        }

        let predicate = HKQuery.predicateForObjects(from: HKSource.default())

        for type in HealthQuantityType.allCases {
            guard let quantity = type.quantity
            else { continue }

            healthStore.deleteObjects(of: quantity, predicate: predicate) { (isDeleted, count, error) in
                if !isDeleted {
                    completion(.failure(error!))
                    return
                }

                removedCount += count
            }
        }

        completion(.success(removedCount / HealthQuantityType.allCases.count))
    }
}

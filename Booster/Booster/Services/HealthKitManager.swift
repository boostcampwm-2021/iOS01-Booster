//
//  HealthKitManager.swift
//  Booster
//
//  Created by Hani on 2021/11/23.
//

import Foundation
import HealthKit

import RxSwift

typealias RxHealthQuantityType = HealthKitManager.HealthQuantityType
typealias RxHealthUnit = HealthKitManager.HealthUnit

final class HealthKitManager {
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

    static let shared = HealthKitManager()

    private var healthStore: HKHealthStore?

    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    func requestAuthorization(shareTypes: Set<HKSampleType>, readTypes: Set<HKSampleType>) -> Single<Bool> {

        return Single.create { [weak self] single in
            self?.healthStore?.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
                guard error == nil
                else { return  }

                return single(.success(success))
            }

            return Disposables.create()
        }
    }

    func requestStatisticsCollectionQuery(type: HKQuantityType,
                                          predicate: NSPredicate,
                                          interval: DateComponents,
                                          anchorDate: Date) -> Single<HKStatisticsCollection> {
        return Single.create { [weak self] single in
            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, hkStatisticsCollection, _ in
                if let hkStatisticsCollection = hkStatisticsCollection {
                    return single(.success(hkStatisticsCollection))
                }
            }

            self?.healthStore?.execute(query)

            return Disposables.create()
        }
    }

    func requestStatisticsQuery(type: HKQuantityType, predicate: NSPredicate) -> Single<HKStatistics?> {
        return Single.create { [weak self] single in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: [.cumulativeSum, .duration]) { _, statistics, _ in
                    return single(.success(statistics))
                }

            self?.healthStore?.execute(query)

            return Disposables.create()
        }
    }

    func save(count: Double,
              start: Date,
              end: Date,
              quantity: HealthQuantityType,
              unit: HealthUnit) {
        guard let healthStore = healthStore,
                let type = quantity.quantity
        else { return }

        let unit = unit.unit
        let countQuantity = HKQuantity(unit: unit, doubleValue: count)
        let sample = HKQuantitySample(type: type,
                                      quantity: countQuantity,
                                      start: start,
                                      end: end)

        healthStore.save(sample) { _, _ in }
    }
}

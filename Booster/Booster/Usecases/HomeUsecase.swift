//
//  HomeUsecase.swift
//  Booster
//
//  Created by hiju on 2021/11/14.
//
import Foundation
import HealthKit
import RxSwift

final class HomeUsecase {
    func fetchHourlyStepCountsData() -> Observable<HKStatistics> {
        return Observable.create { [weak self] observer in
            guard let stepCountSampleType = HKSampleType.quantityType(forIdentifier: .stepCount),
                  let anchorDate = Calendar.current.date(bySettingHour: 0,
                                                         minute: 0,
                                                         second: 0,
                                                         of: Date()),
                  let predicate = self?.createTodayPredicate()
            else { return Disposables.create() }

            let now = Date()

            HealthStoreManager.shared.requestStatisticsCollectionQuery(type: stepCountSampleType,
                                                                       predicate: predicate,
                                                                       interval: DateComponents(hour: 1),
                                                                       anchorDate: anchorDate) { result in
                result.enumerateStatistics(from: Calendar.current.startOfDay(for: now),
                                           to: now,
                                           with: { statistics, _ in
                    observer.onNext(statistics)
                })
            }
            return Disposables.create()
        }
    }

    func fetchTodayTotalData(type: HKQuantityTypeIdentifier) -> Observable<HKStatistics> {
        return Observable.create { observer in
            guard let sampleType = HKSampleType.quantityType(forIdentifier: type)
            else { return Disposables.create() }

            let now = Date()
            let start = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: start,
                                                        end: now,
                                                        options: .strictStartDate)

            HealthStoreManager.shared.requestStatisticsQuery(type: sampleType, predicate: predicate) { result in
                observer.onNext(result)
            }
            return Disposables.create()
        }
    }

    private func createTodayPredicate(end: Date = Date()) -> NSPredicate {
        return HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: end),
                                           end: end,
                                           options: .strictStartDate)
    }
}

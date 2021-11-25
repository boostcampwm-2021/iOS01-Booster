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
    private let disposeBag = DisposeBag()

    func fetchHourlyStepCountsData() -> Observable<HKStatistics> {
        return Observable.create { [weak self] observer in
            guard let self = self,
                  let stepCountSampleType = HKSampleType.quantityType(forIdentifier: .stepCount),
                  let anchorDate = Calendar.current.date(bySettingHour: 0,
                                                         minute: 0,
                                                         second: 0,
                                                         of: Date()),
                  let now = Calendar.current.date(byAdding: .hour, value: 23, to: anchorDate)
            else { return Disposables.create() }

            let predicate = HKQuery.predicateForSamples(withStart: anchorDate,
                                                        end: now,
                                                        options: .strictStartDate)
            let observable = HealthKitManager.shared.requestStatisticsCollectionQuery(type: stepCountSampleType,
                                                                       predicate: predicate,
                                                                       interval: DateComponents(hour: 1),
                                                                       anchorDate: anchorDate)
            observable.subscribe { hkStatisticsCollection in
                hkStatisticsCollection.enumerateStatistics(from: Calendar.current.startOfDay(for: now),
                                                           to: now,
                                                           with: { statistics, _ in
                    observer.onNext(statistics)
                })
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func fetchTodayTotalData(type: HKQuantityTypeIdentifier) -> Observable<HKStatistics> {
        return Observable.create { [weak self] observer in
            guard let self = self,
                  let sampleType = HKSampleType.quantityType(forIdentifier: type)
            else { return Disposables.create() }

            let now = Date()
            let start = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: start,
                                                        end: now,
                                                        options: .strictStartDate)

            HealthKitManager.shared.requestStatisticsQuery(type: sampleType, predicate: predicate).subscribe { result in
                observer.onNext(result)
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
}

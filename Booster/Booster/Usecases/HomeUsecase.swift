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

    func fetchHourlyStepCountsData() -> Observable<StepStatisticsCollection> {
        return Observable.create { [weak self] observer in
            let anchorDate = Calendar.current.startOfDay(for: Date())
            guard let self = self,
                  let stepCountSampleType = HKSampleType.quantityType(forIdentifier: .stepCount),
                  let endDate = Calendar.current.date(byAdding: .hour,
                                                      value: 23,
                                                      to: anchorDate)
            else { return Disposables.create() }

            let predicate = HKQuery.predicateForSamples(withStart: anchorDate,
                                                        end: endDate,
                                                        options: .strictStartDate)

            let observable = HealthKitManager.shared.requestStatisticsCollectionQuery(type: stepCountSampleType,
                                                                       predicate: predicate,
                                                                       interval: DateComponents(hour: 1),
                                                                       anchorDate: anchorDate)

            observable.subscribe { hkStatisticsCollection in
                guard let hkStatisticsCollection = hkStatisticsCollection.element
                else { return }

                var stepStatisticsCollection = StepStatisticsCollection()

                hkStatisticsCollection.enumerateStatistics(from: anchorDate,
                                                           to: endDate,
                                                           with: { hkstatistics, _ in

                    let step = Int(hkstatistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    let date = hkstatistics.startDate
                    let stepStatistics = self.configureStepStatistics(step: step, date: date)
                    stepStatisticsCollection.append(stepStatistics)
                })

                observer.onNext(stepStatisticsCollection)
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    private func configureStepStatistics(step: Int, date: Date) -> StepStatistics {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "H"

        let string = dateFormatter.string(from: date)

        return StepStatistics(step: step, abbreviatedDateString: string)
    }

    func fetchTodayTotalData(type: HKQuantityTypeIdentifier) -> Observable<HKStatistics?> {
        return Observable.create { [weak self] observer in
            guard let self = self,
                  let sampleType = HKSampleType.quantityType(forIdentifier: type)
            else { return Disposables.create() }

            let now = Date()
            let start = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: start,
                                                        end: now,
                                                        options: .strictStartDate)

            let observable = HealthKitManager.shared.requestStatisticsQuery(type: sampleType, predicate: predicate)
            observable.subscribe { result in
               observer.onNext(result)
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
}

//
//  StatisticsUsecase.swift
//  Booster
//
//  Created by Hani on 2021/11/17.
//

import Foundation
import HealthKit

import RxSwift

final class StatisticsUsecase {
    func execute(duration: Calendar.Component,
                 interval: DateComponents) -> Observable<StepStatisticsCollection> {
        return Observable.create { [weak self] observer in
            guard let self = self,
                  let type = HKQuantityType.quantityType(forIdentifier: .stepCount)
            else { return Disposables.create() }

            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = Locale(identifier: "ko_KR")

            let anchorDate = calendar.startOfDay(for: Date())

            guard let startDate = calendar.date(byAdding: duration,
                                                value: -1,
                                                to: anchorDate) else { return Disposables.create() }

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: anchorDate)

            HealthStoreManager.shared.requestStatisticsCollectionQuery(type: type,
                                                                       predicate: predicate,
                                                                       interval: interval,
                                                                       anchorDate: anchorDate) { hkStatisticsCollection in

                let durationString = self.configureDurationString(startDate: startDate, endDate: anchorDate)

                var stepStatisticsCollection = StepStatisticsCollection(durationString: durationString)

                hkStatisticsCollection.enumerateStatistics(from: startDate, to: anchorDate) { (statistics, _) in
                    guard let quantity = statistics.sumQuantity(),
                          let startDate = calendar.date(byAdding: .day, value: 1, to: statistics.startDate)
                    else { return }

                    let endDate = statistics.endDate

                    let step = Int(quantity.doubleValue(for: .count()))
                    let intervalString = self.configureIntervalString(startDate: startDate, endDate: endDate)
                    let abbreviatedDateString = self.configureAbbreviatedDateString(startDate: startDate, interval: interval)

                    let stepStatistics = StepStatistics(step: step,
                                                        intervalString: intervalString,
                                                        abbreviatedDateString: abbreviatedDateString)

                    stepStatisticsCollection.append(stepStatistics)
                }

                observer.onNext(stepStatisticsCollection)
            }

            return Disposables.create()
        }
    }

    private func configureDurationString(startDate: Date, endDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"

        return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
    }

    private func configureIntervalString(startDate: Date, endDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yy.MM.dd"

        let startDateString = dateFormatter.string(from: startDate)

        var calendar = Calendar.init(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")

        let startDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        let endDateComponents   = calendar.dateComponents([.year, .month, .day], from: endDate)

        if startDateComponents.year != endDateComponents.year {
            return "\(startDateString) - \(dateFormatter.string(from: endDate))"

        } else if startDateComponents.month != endDateComponents.month {
            dateFormatter.dateFormat = "MM.dd"
            return "\(startDateString) - \(dateFormatter.string(from: endDate))"

        } else if startDateComponents.day != endDateComponents.day {
            dateFormatter.dateFormat = "dd"
            return "\(startDateString) - \(dateFormatter.string(from: endDate))"

        } else {
            return "\(startDateString)"
        }
    }

    private func configureAbbreviatedDateString(startDate: Date, interval: DateComponents) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")

        switch interval {
        case .init(day: 1):
            dateFormatter.dateFormat = "E"
        case .init(weekOfMonth: 1):
            dateFormatter.dateFormat = "d"
        case .init(month: 1):
            dateFormatter.dateFormat = "MMM"
        default:
            return String()
        }

        return dateFormatter.string(from: startDate)
    }
}

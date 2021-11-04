import Foundation
import HealthKit

final class StatisticsViewModel {

    // MARK: - Variables

    private let healthStore = HKHealthStore()

    private var weekStatistics  = StatisticsCollection()
    private var monthStatistics = StatisticsCollection()
    private var yearStatistics  = StatisticsCollection()

    // MARK: - functions

    func statistics(for button: Button) -> StatisticsCollection {
        switch button {
        case .week:
            return self.weekStatistics
        case .month:
            return self.monthStatistics
        case .year:
            return self.yearStatistics
        }
    }

    func queryStepCount() {
        queryStepCountForWeek()
        queryStepCountForMonth()
        queryStepCountForYear()
    }

    private func queryStepCountForWeek() {
        queryStepCount(for: .week) { result in
            self.weekStatistics = result
        }
    }
    private func queryStepCountForMonth() {
        queryStepCount(for: .month) { result in
            self.monthStatistics = result
        }
    }
    private func queryStepCountForYear() {
        queryStepCount(for: .year) { result in
            self.yearStatistics = result
        }
    }

    private func queryStepCount(for button: Button, completion: @escaping (StatisticsCollection) -> Void ) {
        var interval: DateComponents
        var duration: Calendar.Component
        switch button {
        case .week:
            interval = DateComponents(day: 1)
            duration = .weekOfMonth
        case .month:
            interval = DateComponents(day: 1)
            duration = .month
        case .year:
            interval = DateComponents(month: 1)
            duration = .year
        }

        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let oneyearago = Calendar.current.date(byAdding: duration, value: -1, to: Date()) else { return }
        let startDate = Calendar.current.startOfDay(for: oneyearago)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: .now, options: [.strictStartDate, .strictEndDate])

        let anchorDate = Calendar.current.startOfDay(for: Date())

        HealthStoreManager.shared.requestStatisticsCollectionQuery(type: stepCountType,
                                                                   predicate: predicate,
                                                                   interval: interval,
                                                                   anchorDate: anchorDate) { hkStatisticsCollection in

            var statisticsCollection = StatisticsCollection()

            hkStatisticsCollection.enumerateStatistics(from: startDate, to: anchorDate) { (statistics, _) in
                if let quantity = statistics.sumQuantity() {
                    let step = Int(quantity.doubleValue(for: .count()))
                    let date = statistics.startDate
                    let statistics = Statistics(date: date, step: step)
                    statisticsCollection.append(statistics: statistics)
                }
            }
            completion(statisticsCollection)

        }
    }

}

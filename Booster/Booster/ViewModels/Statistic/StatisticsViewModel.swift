import Foundation
import HealthKit

final class StatisticsViewModel {
    // MARK: - Enums
    enum Duration {
        case week, month, year
    }

    // MARK: - Properties
    private var weekStatistics  = StatisticsCollection()
    private var monthStatistics = StatisticsCollection()
    private var yearStatistics  = StatisticsCollection()

    var selectedDuration: Observable<Duration> = Observable(.week)
    var selectedStatistics: Observable<(index: Int?, coordinate: Float?)> = Observable((nil, nil))

    // MARK: - functions
    func statistics() -> StatisticsCollection {
        switch selectedDuration.value {
        case .week:
            return weekStatistics
        case .month:
            return monthStatistics
        case .year:
            return yearStatistics
        }
    }

    func queryStepCount() {
        queryStepCountForWeek()
        queryStepCountForMonth()
        queryStepCountForYear()
    }

    func tapStatistics(at xCoordinate: Float) {
        let statisticsCollection: StatisticsCollection = statistics()
        let offset = 1 / Float(statisticsCollection.count)
        var selectedIndex: Int = -1

        for index in 0..<statisticsCollection.count {
            if (Float(index) * offset...Float(index + 1) * offset).contains(xCoordinate) {
                selectedIndex = index
                break
            }
        }

        if selectedStatistics.value.index == selectedIndex {
            selectedStatistics.value = (index: nil, coordinate: nil)
        } else {
            selectedStatistics.value = (index: selectedIndex, coordinate: Float(selectedIndex) * offset + offset / 2)
        }
    }

    func panStatistics(at xCoordinate: Float) {
        let statisticsCollection: StatisticsCollection = statistics()
        let offset = 1 / Float(statisticsCollection.count)
        var selectedIndex: Int = -1

        for index in 0..<statisticsCollection.count {
            if (Float(index) * offset...Float(index + 1) * offset).contains(xCoordinate) {
                selectedIndex = index
                break
            }
        }

        if selectedStatistics.value.index != selectedIndex {
            selectedStatistics.value = (index: selectedIndex, coordinate: Float(selectedIndex) * offset + offset / 2)
        }
    }

    private func queryStepCountForWeek() {
        queryStepCount(for: .week) { [weak self] result in
            self?.weekStatistics = result
        }
    }
    private func queryStepCountForMonth() {
        queryStepCount(for: .month) { [weak self] result in
            self?.monthStatistics = result
        }
    }
    private func queryStepCountForYear() {
        queryStepCount(for: .year) { [weak self] result in
            self?.yearStatistics = result
        }
    }

    private func queryStepCount(for button: Duration, completion: @escaping (StatisticsCollection) -> Void) {
        var interval: DateComponents
        var duration: Calendar.Component

        switch button {
        case .week:
            interval = DateComponents(day: 1)
            duration = .weekOfMonth
        case .month:
            interval = DateComponents(weekOfMonth: 1)
            duration = .month
        case .year:
            interval = DateComponents(month: 1)
            duration = .year
        }

        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let past = Calendar.current.date(byAdding: duration,
                                                     value: -1,
                                                     to: Date())
        else { return }

        let startDate = Calendar.current.startOfDay(for: past)
        let anchorDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: Date(),
                                                    options: [])

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

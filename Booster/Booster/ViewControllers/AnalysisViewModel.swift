import Foundation
import HealthKit

final class AnalysisViewModel {

  // MARK: - Enum

  enum Button {
    case week, month, year
  }

  // MARK: - Variables

  private let healthStore = HKHealthStore()

  private(set) var weekAnalysis: Analysis?
  private(set) var monthAnalysis: Analysis?
  private(set) var yearAnalysis: Analysis?

  private(set) var tappedButton: Observable<Button> = Observable(.week)

  // MARK: - init

  init() {
    queryStepCount()
  }

  // MARK: - functions

  func updateTappedButton(_ button: Button) {
    tappedButton = Observable(button)
  }

  private func queryStepCount() {
    queryStepCountForEveryWeek()
    queryStepCountForEveryMonth()
    queryStepCountForEveryYear()
  }

  private func queryStepCountForEveryWeek() {
    guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
          let oneyearago = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else { return }

    let startDate = Calendar.current.startOfDay(for: oneyearago)
    let interval = DateComponents(day: 1)
    let sample = HKQuery.predicateForSamples(withStart: startDate, end: .now, options: .strictStartDate)
    let anchorDate = Calendar.current.startOfDay(for: Date())
    let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
                                            quantitySamplePredicate: sample,
                                            options: .cumulativeSum,
                                            anchorDate: anchorDate,
                                            intervalComponents: interval)

    query.initialResultsHandler = { [weak self] _, statisticsCollection, _ in
      if let statisticsCollection = statisticsCollection {
        var dates = [String]()
        var steps = [Int]()

        statisticsCollection.enumerateStatistics(from: startDate, to: anchorDate) { (statistics, _) in
            let step = Int(statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            let date = String(describing: statistics.startDate)
            steps.append(step)
            dates.append(date)
          }

          self?.weekAnalysis = Analysis(dates: dates, steps: steps)
        }
      }

    self.healthStore.execute(query)
  }

  private func queryStepCountForEveryMonth() {
    guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let oneyearago = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else { return }

    let startDate = Calendar.current.startOfDay(for: oneyearago)
    let interval = DateComponents(day: 7)
    let sample = HKQuery.predicateForSamples(withStart: startDate, end: .now, options: .strictStartDate)
    let anchorDate = Calendar.current.startOfDay(for: Date())
    let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
                                            quantitySamplePredicate: sample,
                                            options: .cumulativeSum,
                                            anchorDate: anchorDate,
                                            intervalComponents: interval)

    query.initialResultsHandler = { [weak self] _, statisticsCollection, _ in
      if let statisticsCollection = statisticsCollection {

        var dates = [String]()
        var steps = [Int]()

        statisticsCollection.enumerateStatistics(from: startDate, to: anchorDate) { (statistics, _) in

          let step = Int(statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)
          let date = String(describing: statistics.startDate)
          steps.append(step)
          dates.append(date)
        }

        self?.monthAnalysis = Analysis(dates: dates, steps: steps)
      }
    }

    self.healthStore.execute(query)
  }

  private func queryStepCountForEveryYear() {
    guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
          let oneyearago = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else { return }

    let startDate = Calendar.current.startOfDay(for: oneyearago)
    let interval = DateComponents(month: 1)
    let sample = HKQuery.predicateForSamples(withStart: startDate, end: .now, options: .strictStartDate)
    let anchorDate = Calendar.current.startOfDay(for: Date())
    let query = HKStatisticsCollectionQuery(quantityType: stepCountType,
                                            quantitySamplePredicate: sample,
                                            options: .cumulativeSum,
                                            anchorDate: anchorDate,
                                            intervalComponents: interval)

    query.initialResultsHandler = {  [weak self] _, statisticsCollection, _ in
      if let statisticsCollection = statisticsCollection {
        var dates = [String]()
        var steps = [Int]()

        statisticsCollection.enumerateStatistics(from: startDate, to: anchorDate) { (statistics, _) in

          let step = Int(statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)
          let date = String(describing: statistics.startDate)
          steps.append(step)
          dates.append(date)

        }

        self?.yearAnalysis = Analysis(dates: dates, steps: steps)
      }
    }

    self.healthStore.execute(query)
  }
}

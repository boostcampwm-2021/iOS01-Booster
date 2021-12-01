//
//  StepStatitstics.swift
//  Booster
//
//  Created by Hani on 2021/11/17.
//

import Foundation

struct StepStatistics {
    let step: Int
    let abbreviatedDateString: String
    let intervalString: String

    init(step: Int, abbreviatedDateString: String, intervalString: String = String()) {
        self.step = step
        self.abbreviatedDateString = abbreviatedDateString
        self.intervalString = intervalString
    }
}

extension StepStatistics: Comparable {
    static func < (lhs: StepStatistics, rhs: StepStatistics) -> Bool {
        lhs.step < rhs.step
    }
}

struct StepStatisticsCollection {
    private var stepStatisticsCollection = [StepStatistics]()

    var durationString: String?

    var count: Int { stepStatisticsCollection.count }

    subscript (index: Int) -> StepStatistics {
        return stepStatisticsCollection[index]
    }

    private func maxStepStatistics() -> StepStatistics? {
        guard let maxStepStatistics = stepStatisticsCollection.first
        else { return nil }

        return stepStatisticsCollection.reduce(maxStepStatistics) { max($0, $1) }
    }

    mutating func append(_ stepStatistics: StepStatistics) {
        stepStatisticsCollection.append(stepStatistics)
    }

    func stepCountPerDuration() -> Int? {
        guard stepStatisticsCollection.count > 0
        else { return nil }

        return stepStatisticsCollection.reduce(0) { $0 + $1.step } / stepStatisticsCollection.count
    }

    func stepRatios() -> [Float] {
        guard let maxStepStatistics = maxStepStatistics(),
              maxStepStatistics.step > 0
        else { return [Float](repeating: 0, count: stepStatisticsCollection.count) }

        return stepStatisticsCollection.map { Float($0.step) / Float(maxStepStatistics.step) }
    }

    func abbreviatedStrings() -> [String] {
        return stepStatisticsCollection.map { $0.abbreviatedDateString }
    }
}

//
//  HomeModel.swift
//  Booster
//
//  Created by hiju on 2021/11/03.
//

import Foundation

struct HomeModel {
    var kcal: Int
    var km: Double
    var activeTime: TimeInterval
    var goal: Int
    var totalStepCount: Int
    var hourlyStatistics: StepStatisticsCollection

    init() {
        kcal = 0
        km = 0.0
        activeTime = 0
        goal = 10000
        totalStepCount = 0
        hourlyStatistics = StepStatisticsCollection()
    }

    func gradientRatio() -> Double {
        guard goal > 0
        else { return Double(0) }

        return (Double(totalStepCount) / Double(goal))
    }
    
    func stepRatios() -> [Float]? {
        hourlyStatistics.stepRatios()
    }
}

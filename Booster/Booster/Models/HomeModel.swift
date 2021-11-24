//
//  HomeData.swift
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
        goal = 0
        totalStepCount = 0
        hourlyStatistics = StepStatisticsCollection()
    }
}

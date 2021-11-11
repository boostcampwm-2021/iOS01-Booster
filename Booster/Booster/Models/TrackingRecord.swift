//
//  TrackingRecord.swift
//  Booster
//
//  Created by hiju on 2021/11/03.
//

import Foundation

struct TrackingRecords {
    var count: Int { return list.count }

    private var list: [TrackingRecord] = []

    subscript(_ index: Int) -> TrackingRecord? {
        if index > list.count-1 || index < 0 { return nil }
        return list[index]
    }

    mutating func appendAll(_ data: [TrackingRecord]) {
        list += data
    }

    mutating func list(contetsOf list: [TrackingRecord]) {
        self.list = list
    }
}

struct TrackingRecord {
    let title: String
    let date: Date
    let distance: Double
    let totalSteps: Int
    let imageData: Data
}

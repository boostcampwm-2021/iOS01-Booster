//
//  FeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/03.
//

import Foundation

final class FeedViewModel {
    var trackingRecords: Observable<TrackingRecords> = Observable(TrackingRecords())

    init() { configureTableViewData() }

    func recordCount() -> Int {
        return trackingRecords.value.count
    }

    func dataAtIndex(_ index: Int) -> TrackingRecord? {
        return trackingRecords.value[index]
    }

    private func configureTableViewData() {
        let model: [TrackingRecord] = [TrackingRecord(title: "토요일 야간 산책",
                                                      date: Date(),
                                                      km: 2.21,
                                                      totalSteps: 1002),
                                       TrackingRecord(title: "일요일 야간 산책",
                                                      date: Date(),
                                                      km: 10.213,
                                                      totalSteps: 15007),
                                       TrackingRecord(title: "월요일 냥냥이랑 오전 산책",
                                                      date: Date(),
                                                      km: 5.10,
                                                      totalSteps: 53226),
                                       TrackingRecord(title: "화욜 정연이랑 밤산책",
                                                      date: Date(),
                                                      km: 1.21,
                                                      totalSteps: 4069)]
        trackingRecords.value.appendAll(model)
    }
}

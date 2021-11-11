//
//  FeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/03.
//

import Foundation

typealias FeedCellConfigure = CollectionCellConfigurator<FeedCell, (date: Date,
                                                                    distance: Double,
                                                                    step: Int,
                                                                    imageData: Data)>

final class FeedViewModel {
    subscript(indexPath: IndexPath) -> CellConfigurator {
        return FeedCellConfigure(item: (date: trackingRecords.value[indexPath.row].date,
                                        distance: trackingRecords.value[indexPath.row].distance,
                                        step: trackingRecords.value[indexPath.row].totalSteps,
                                        imageData: trackingRecords.value[indexPath.row].imageData))
    }

    var trackingRecords: Observable<[TrackingRecord]>
    let usecase: FeedUseCase

    init() {
        usecase = FeedUseCase()
        trackingRecords = Observable([])
    }

    func recordCount() -> Int {
        return trackingRecords.value.count
    }

    func dataAtIndex(_ index: Int) -> TrackingRecord? {
        return trackingRecords.value[index]
    }

    func fetch() {
        usecase.fetch { [weak self] result in
            self?.trackingRecords.value = result
        }
    }
}

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
                                                                    imageData: Data,
                                                                    isEmpty: Bool)>

final class FeedViewModel {
    subscript(indexPath: IndexPath) -> CellConfigurator {
        return FeedCellConfigure(item: (date: trackingRecords.value[indexPath.row].startDate,
                                        distance: trackingRecords.value[indexPath.row].distance,
                                        step: trackingRecords.value[indexPath.row].steps,
                                        imageData: trackingRecords.value[indexPath.row].imageData,
                                        isEmpty: recordCount() == 0))
    }

    private(set) var trackingRecords: Observable<[TrackingModel]>
    private var selectedIndex: IndexPath
    private let usecase: FeedUseCase

    init() {
        selectedIndex = IndexPath()
        usecase = FeedUseCase()
        trackingRecords = Observable([])
    }

    func recordCount() -> Int {
        return trackingRecords.value.count
    }

    func selected(_ index: IndexPath) {
        self.selectedIndex = index
    }

    func selected() -> TrackingModel {
        return trackingRecords.value[selectedIndex.row]
    }

    func fetch() {
        usecase.fetch { [weak self] result in
            self?.trackingRecords.value = result
        }
    }
}

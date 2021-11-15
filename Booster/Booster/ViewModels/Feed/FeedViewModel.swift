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
                                                                    title: String,
                                                                    imageData: Data,
                                                                    isEmpty: Bool)>

final class FeedViewModel {
    subscript(indexPath: IndexPath) -> CellConfigurator {
        let isEmpty = recordCount() == 0
        return FeedCellConfigure(item: (date: isEmpty ? Date() : trackingRecords.value[indexPath.row].startDate,
                                        distance: isEmpty ? 0 : trackingRecords.value[indexPath.row].distance,
                                        step: isEmpty ? 0 : trackingRecords.value[indexPath.row].steps,
                                        title: isEmpty ? "" : trackingRecords.value[indexPath.row].title,
                                        imageData: isEmpty ? Data() : trackingRecords.value[indexPath.row].imageData,
                                        isEmpty: recordCount() == 0))
    }

    private(set) var trackingRecords: Observable<[FeedList]>
    private var selectedIndex: IndexPath
    private var difference: Int
    private let usecase: FeedUseCase

    init() {
        difference = 0
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

    func selected() -> Date {
        return trackingRecords.value[selectedIndex.row].startDate
    }

    func reset() {
        difference = 0
        fetch()
    }

    func fetch() {
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()

        if let date = calendar.date(byAdding: .day, value: difference, to: currentDate) {
            let predicate = NSPredicate(format: "startDate <= %@", date as CVarArg)
            usecase.fetch(predicate: predicate) { [weak self] result in
                if result.count == 0 { return }

                self?.asyncFetch(calendar: calendar, currentDate: currentDate)
            }
        }
    }

    private func asyncFetch(calendar: Calendar, currentDate: Date) {
        if let date = calendar.date(byAdding: .day, value: difference, to: currentDate) as NSDate? {
            let predicate = NSPredicate(format: "startDate >= %@", date as CVarArg)
            usecase.fetch(predicate: predicate) { [weak self] response in
                guard let self = self
                else { return }
                if response.count == 0 {
                    self.difference -= 7
                    self.asyncFetch(calendar: calendar, currentDate: currentDate)
                } else {
                    self.trackingRecords.value = response
                }
            }
        }
    }
}

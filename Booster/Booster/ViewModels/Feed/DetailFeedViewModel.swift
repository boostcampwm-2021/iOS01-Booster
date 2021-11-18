//
//  DetailFeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import Foundation

final class DetailFeedViewModel {
    // MARK: - Properties
    private let usecase: DetailFeedUsecase
    var trackingModel: BoosterObservable<TrackingModel>

    // MARK: - Init
    init() {
        trackingModel = BoosterObservable(TrackingModel())
        usecase = DetailFeedUsecase()
    }

    // MARK: - Functions
    func fetchDetailFeedList(start date: Date) {
        let predicate = NSPredicate(format: "startDate = %@", (date as NSDate) as CVarArg)
        usecase.fetch(predicate: predicate) { [weak self] result in
            if let model = result.first {
                self?.trackingModel.value = model
            }
        }
    }

    func mileStone(at coordinate: Coordinate) -> MileStone? {
        let target = trackingModel.value.milestones.first(where: { (value) in
            return value.coordinate == coordinate
        })

        return target
    }

    func remove(of mileStone: MileStone) -> MileStone? {
        guard let index = trackingModel.value.milestones.firstIndex(of: mileStone)
        else { return nil }

        return trackingModel.value.milestones.remove(at: index)
    }
}

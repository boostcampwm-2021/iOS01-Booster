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
    let startDate: Date
    var trackingModel: BoosterObservable<TrackingModel>

    // MARK: - Init
    init(start date: Date) {
        startDate = date
        trackingModel = BoosterObservable(TrackingModel())
        usecase = DetailFeedUsecase()
    }

    // MARK: - Functions
    func fetchDetailFeedList() {
        let predicate = NSPredicate(format: "startDate = %@", (startDate as NSDate) as CVarArg)
        usecase.fetch(predicate: predicate) { [weak self] result in
            print("result", result)
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

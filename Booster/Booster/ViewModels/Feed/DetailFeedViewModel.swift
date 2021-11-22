//
//  DetailFeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import Foundation

final class DetailFeedViewModel {
    // MARK: - Properties
    let startDate: Date
    var trackingModel: BoosterObservable<TrackingModel>
    private let usecase: DetailFeedUsecase
    private var gradientColorOffset = -1

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
            if let model = result.first {
                self?.trackingModel.value = model
            }
        }
    }

    func milestone(at coordinate: Coordinate) -> Milestone? {
        let target = trackingModel.value.milestones.first(where: { value in
            return value.coordinate == coordinate
        })

        return target
    }

    func reset() { gradientColorOffset = -1 }

    func remove(of milestone: Milestone) -> Milestone? {
        guard let index = trackingModel.value.milestones.firstIndex(of: milestone)
        else { return nil }

        return trackingModel.value.milestones.remove(at: index)
    }

    func indexOfCoordinate(at coordinate: Coordinate) -> Int {
        for (index, model) in trackingModel.value.coordinates.enumerated() {
            guard let latitude = model.latitude,
                  let longitude = model.longitude
            else { continue }
            if abs((coordinate.latitude ?? 0) - latitude) < 0.00000000001 && abs((coordinate.longitude ?? 0) - longitude) < 0.00000000001 {
                return index
            }
        }
        return 0
    }

    func offsetOfGradientColor() -> Int {
        gradientColorOffset += 1
        return gradientColorOffset
    }
}

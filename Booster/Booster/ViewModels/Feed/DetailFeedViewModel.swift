//
//  DetailFeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import Foundation

final class DetailFeedViewModel {
    private let usecase: DetailFeedUsecase
    var trackingModel: Observable<TrackingModel>

    init() {
        trackingModel = Observable(TrackingModel())
        usecase = DetailFeedUsecase()
    }

    func update(start date: Date) {
        let predicate = NSPredicate(format: "startDate = %@", (date as NSDate) as CVarArg)
        usecase.fetch(predicate: predicate) { [weak self] result in
            if let model = result.first {
                self?.trackingModel.value = model
            }
        }
    }
}

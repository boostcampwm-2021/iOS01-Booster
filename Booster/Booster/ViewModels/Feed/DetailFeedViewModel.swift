//
//  DetailFeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import Foundation

final class DetailFeedViewModel {
    var trackingModel: Observable<TrackingModel>

    init() {
        trackingModel = Observable(TrackingModel())
    }

    func configure(model: TrackingModel) {
        trackingModel.value = model
    }
}

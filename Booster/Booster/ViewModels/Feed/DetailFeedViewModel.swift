//
//  DetailFeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import Foundation

final class DetailFeedViewModel {
    var trackingModel: Observable<[Tracking]> = Observable([Tracking]())

    private let detailFeedUseCase: DetailFeedUsecase

    init(detailFeedUseCase: DetailFeedUsecase) {
        self.detailFeedUseCase = detailFeedUseCase

        configure()
    }

    private func configure() {
        detailFeedUseCase.execute { response in
            switch response {
            case .success(let model):
                self.trackingModel.value = model
            case .failure:
                break
            }
        }
    }
}

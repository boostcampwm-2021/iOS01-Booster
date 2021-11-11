//
//  FeedUseCase.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/10.
//

import Foundation

class FeedUseCase {
    enum EntityName {
        static let tracking = "Tracking"
    }

    private let repository: RepositoryManager
    private let entity: String

    init() {
        entity = "Tracking"
        repository = RepositoryManager()
    }

    func fetch(completion handler: @escaping ([TrackingRecord]) -> Void) {
        repository.fetch { (response: Result<[Tracking], Error>) in
            switch response {
            case .success(let result):
                var trackingModels: [TrackingRecord] = []
                result.forEach { value in
                    if let startDate = value.startDate,
                       let title = value.title,
                       let imageData = value.imageData {
                        let trackingRecord = TrackingRecord(title: title,
                                                            date: startDate,
                                                            distance: value.distance,
                                                            totalSteps: Int(value.steps),
                                                            imageData: imageData)
                        trackingModels.append(trackingRecord)
                    }

                    handler(trackingModels)
                }

            case .failure:
                handler([])
            }
        }
    }
}

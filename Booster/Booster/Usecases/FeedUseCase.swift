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

    func fetch(completion handler: @escaping ([TrackingModel]) -> Void) {
        repository.fetch { (response: Result<[Tracking], Error>) in
            switch response {
            case .success(let result):
                var trackingModels: [TrackingModel] = []
                result.forEach { value in
                    if let startDate = value.startDate,
                       let coordinatesData = value.coordinates,
                       let milestonesData = value.milestones,
                       let coordinates = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(coordinatesData) as? [Coordinate],
                       let milestones = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(milestonesData) as? [MileStone],
                       let title = value.title,
                       let content = value.content,
                       let imageData = value.imageData,
                       let endDate = value.endDate {
                        let trackingModel = TrackingModel(startDate: startDate,
                                                          endDate: endDate,
                                                          steps: Int(value.steps),
                                                          calories: Int(value.calories),
                                                          seconds: Int(value.seconds),
                                                          distance: value.distance,
                                                          coordinates: coordinates,
                                                          milestones: milestones,
                                                          title: title,
                                                          content: content,
                                                          imageData: imageData)
                        trackingModels.append(trackingModel)
                    }

                    handler(trackingModels)
                }

            case .failure:
                handler([])
            }
        }
    }
}

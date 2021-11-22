//
//  DetailFeedUsecase.swift
//  Booster
//
//  Created by hiju on 2021/11/11.
//

import Foundation
import CoreData

final class DetailFeedUsecase {
    private let entityName: String

    init() {
        entityName = "Tracking"
    }

    func fetch(predicate: NSPredicate, completion handler: @escaping ([TrackingModel]) -> Void) {
        CoreDataManager.shared.fetch(entityName: entityName, predicate: predicate) { (response: Result<[Tracking], Error>) in
            switch response {
            case .success(let result):
                var trackingModels: [TrackingModel] = []
                result.forEach { [weak self] value in
                    if let trackingModel = self?.convert(tracking: value) {
                        trackingModels.append(trackingModel)
                    }
                }
                handler(trackingModels)
            case .failure:
                handler([])
            }
        }
    }

    private func convert(tracking: Tracking) -> TrackingModel? {
        if let startDate = tracking.startDate,
           let coordinatesData = tracking.coordinates,
           let milestonesData = tracking.milestones,
           let coordinates = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(coordinatesData) as? [Coordinate],
           let milestones = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(milestonesData) as? [Milestone],
           let title = tracking.title,
           let content = tracking.content,
           let imageData = tracking.imageData,
           let endDate = tracking.endDate {
            let trackingModel = TrackingModel(startDate: startDate,
                                              endDate: endDate,
                                              steps: Int(tracking.steps),
                                              calories: Int(tracking.calories),
                                              seconds: Int(tracking.seconds),
                                              distance: tracking.distance,
                                              coordinates: coordinates,
                                              milestones: milestones,
                                              title: title,
                                              content: content,
                                              imageData: imageData)
            return trackingModel
        }
        return nil
    }
}

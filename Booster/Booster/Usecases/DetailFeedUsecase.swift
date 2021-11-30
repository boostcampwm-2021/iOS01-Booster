//
//  DetailFeedUsecase.swift
//  Booster
//
//  Created by hiju on 2021/11/11.
//

import Foundation
import RxSwift

protocol DetailFeedUsecaseProtocol {
    func update(milestones: [Milestone], predicate: NSPredicate) -> Observable<Void>
    func fetch(predicate: NSPredicate) -> Observable<TrackingModel>
    func remove(predicate: NSPredicate) -> Observable<Void>
}

typealias TrackingSaveError = DetailFeedUsecase.TrackingError

final class DetailFeedUsecase: DetailFeedUsecaseProtocol {
    enum TrackingError: Error {
        case modelError
        case error(Error)
    }

    private let entityName = "Tracking"

    func update(milestones: [Milestone], predicate: NSPredicate) -> Observable<Void> {
        guard let milestones = try? NSKeyedArchiver.archivedData(withRootObject: milestones, requiringSecureCoding: false)
        else {
            return Observable.create { observer in
                observer.onError(TrackingError.modelError)
                return Disposables.create()
            }
        }

        let attributes: [String: Any] = [CoreDataKeys.milestones: milestones]

        return CoreDataManager.shared.update(entityName: entityName,
                                             attributes: attributes,
                                             predicate: predicate)
    }

    func fetch(predicate: NSPredicate) -> Observable<TrackingModel> {
        return CoreDataManager.shared.fetch(entityName: entityName, predicate: predicate)
            .map { (value: [Tracking]) in
                guard let tracking = value.first,
                      let convertModel = self.convert(tracking: tracking)
                else { return TrackingModel() }

                return convertModel
            }
    }

    func remove(predicate: NSPredicate) -> Observable<Void> {
        return CoreDataManager.shared.delete(entityName: entityName, predicate: predicate)
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
                                              coordinates: Coordinates(coordinates: coordinates),
                                              milestones: Milestones(milestones: milestones),
                                              title: title,
                                              content: content,
                                              imageData: imageData)
            return trackingModel
        }
        return nil
    }
}

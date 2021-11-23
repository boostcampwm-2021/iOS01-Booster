//
//  DetailFeedUsecase.swift
//  Booster
//
//  Created by hiju on 2021/11/11.
//

import Foundation
import RxSwift

protocol DetailFeedUsecaseProtocol {
    func update(model: TrackingModel, predicate: NSPredicate) -> Observable<Void>
    func fetch(predicate: NSPredicate) -> Observable<TrackingModel>
    func remove(predicate: NSPredicate) -> Observable<Void>
}

typealias TrackingSaveError = DetailFeedUsecase.TrackingError

final class DetailFeedUsecase: DetailFeedUsecaseProtocol {
    enum TrackingError: Error {
        case modelError
        case error(Error)
    }

    private enum CoreDataKeys {
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let steps = "steps"
        static let calories = "calories"
        static let seconds = "seconds"
        static let distance = "distance"
        static let coordinates = "coordinates"
        static let milestones = "milestones"
        static let title = "title"
        static let content = "content"
        static let imageData = "imageData"
        static let address = "address"
    }

    private let entityName = "Tracking"

    func update(model: TrackingModel, predicate: NSPredicate) -> Observable<Void> {
        guard let coordinates = try? NSKeyedArchiver.archivedData(withRootObject: model.coordinates, requiringSecureCoding: false),
              let milestones = try? NSKeyedArchiver.archivedData(withRootObject: model.milestones, requiringSecureCoding: false),
              let endDate = model.endDate,
              let distance = Double(String(format: "%.2f", model.distance))
        else {
            return Observable.create { observable in
                observable.on(.error(TrackingError.modelError))
                return Disposables.create()
            }
        }

        let value: [String: Any] = [
            CoreDataKeys.startDate: model.startDate,
            CoreDataKeys.endDate: endDate,
            CoreDataKeys.steps: model.steps,
            CoreDataKeys.calories: model.calories,
            CoreDataKeys.seconds: model.seconds,
            CoreDataKeys.distance: distance,
            CoreDataKeys.coordinates: coordinates,
            CoreDataKeys.milestones: milestones,
            CoreDataKeys.title: model.title,
            CoreDataKeys.content: model.content,
            CoreDataKeys.imageData: model.imageData,
            CoreDataKeys.address: model.address
        ]

        return CoreDataManager.shared.update(entityName: entityName,
                                             attributes: value,
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

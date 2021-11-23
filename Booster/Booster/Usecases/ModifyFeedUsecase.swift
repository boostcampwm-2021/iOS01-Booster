//
//  ModifyFeedUsecase.swift
//  Booster
//
//  Created by hiju on 2021/11/23.
//

import Foundation
import RxSwift

protocol ModifyFeedUsecaseProtocol {
    func update(model: WritingRecord, predicate: NSPredicate) -> Observable<Void>
}

typealias ModifyError = ModifyFeedUsecase.ModifyError

final class ModifyFeedUsecase: ModifyFeedUsecaseProtocol {
    enum ModifyError: Error {
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

    func update(model: WritingRecord, predicate: NSPredicate) -> Observable<Void> {
        let attributes: [String: Any] = [
            CoreDataKeys.title: model.title,
            CoreDataKeys.content: model.content
        ]

        return CoreDataManager.shared.update(entityName: entityName,
                                             attributes: attributes,
                                             predicate: predicate)
    }
}

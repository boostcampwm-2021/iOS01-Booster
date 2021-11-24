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

final class ModifyFeedUsecase: ModifyFeedUsecaseProtocol {
    private enum CoreDataKeys {
        static let title = "title"
        static let content = "content"
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

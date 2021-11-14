//
//  FeedUseCase.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/10.
//

import Foundation

class FeedUseCase {
    private let repository: RepositoryManager
    private let entity: String

    init() {
        entity = "Tracking"
        repository = RepositoryManager()
    }

    func fetch(completion handler: @escaping ([FeedList]) -> Void) {
        repository.fetch { (response: Result<[Tracking], Error>) in
            switch response {
            case .success(let result):
                var feedLists: [FeedList] = []
                result.forEach { [weak self] value in
                    if let feedList = self?.convert(tracking: value) {
                        feedLists.append(feedList)
                    }
                }
                handler(feedLists)
            case .failure:
                handler([])
            }
        }
    }

    func fetch(predicate: NSPredicate, completion handler: @escaping ([FeedList]) -> Void) {
        repository.fetch(entityName: entity, predicate: predicate) { (response: Result<[Tracking], Error>) in
            switch response {
            case .success(let result):
                var feedLists: [FeedList] = []
                result.forEach { [weak self] value in
                    if let feedList = self?.convert(tracking: value) {
                        feedLists.append(feedList)
                    }
                }
                handler(feedLists)
            case .failure:
                handler([])
            }
        }
    }

    private func convert(tracking: Tracking) -> FeedList? {
        if let startDate = tracking.startDate,
           let title = tracking.title,
           let imageData = tracking.imageData {
            let feedList = FeedList(startDate: startDate,
                                    steps: Int(tracking.steps),
                                    distance: tracking.distance,
                                    title: title,
                                    imageData: imageData)
            return feedList
        }
        return nil
    }
}

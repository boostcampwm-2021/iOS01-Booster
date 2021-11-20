//
//  FeedUseCase.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/10.
//

import Foundation
import RxSwift

class FeedUseCase {
    func fetch() -> Observable<[FeedList]> {
        return CoreDataManager.shared.fetch()
            .map { (value: [Tracking]) in
                var feedList: [FeedList] = []
                value.forEach {
                    if let feed = self.convert(tracking: $0) {
                        feedList.append(feed)
                    }
                }

                return feedList
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

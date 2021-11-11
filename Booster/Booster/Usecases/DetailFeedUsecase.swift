//
//  DetailFeedUsecase.swift
//  Booster
//
//  Created by hiju on 2021/11/11.
//

import Foundation
import CoreData

final class DetailFeedUsecase {
    private let repository: RepositoryManager

    init(repository: RepositoryManager) {
        self.repository = repository
    }

    func execute(completion: @escaping (ResultType<[Tracking], Error>) -> Void) {
        repository.fetch(type: "Tracking") { response in
            completion(response)
        }
    }
}

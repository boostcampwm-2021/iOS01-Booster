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

    func execute(completion: @escaping (Result<[Tracking], Error>) -> Void) {
        repository.fetch { (response: Result<[Tracking], Error>) in
            completion(response)
        }
    }
}

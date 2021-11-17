//
//  UserViewModel.swift
//  Booster
//
//  Created by mong on 2021/11/16.
//

import Foundation

final class UserViewModel {
    enum UserViewModelError: Error {
        case noData
    }

    private let usecase: UserUsecase
    private var model: UserInfo

    init() {
        usecase = UserUsecase()
        model = UserInfo(age: 25, nickname: "히로롱", gender: "여", height: 164, weight: 80)
    }

    func nickname() -> String {
        return model.nickname
    }

    func userPhysicalInfo() -> String {
        return "\(model.age)살, \(model.height)cm, \(model.weight)kg, \(model.gender)"
    }

    func eraseAllData(completion: @escaping (Result<Int, Error>) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)

        var resultOfHealthKit: Result<Int, Error>?
        var resultOfCoreData: Result<Void, Error>?

        usecase.eraseAllDataOfHealthKit { (result) in
            resultOfHealthKit = result
            semaphore.signal()
        }
        semaphore.wait()

        usecase.eraseAllDataOfCoreData { (result) in
            resultOfCoreData = result
            semaphore.signal()
        }
        semaphore.wait()

        guard let resultOfHealthKit = try? resultOfHealthKit?.get(),
              let resultOfCoreData = try? resultOfCoreData?.get()
        else {
            completion(.failure(UserViewModelError.noData))
            return
        }

        completion(.success(resultOfHealthKit))
    }

    func editUserInfo(gender: String? = nil, age: Int? = nil, height: Int? = nil, weight: Int? = nil, nickname: String? = nil) {
        if let gender = gender { model.gender = gender }
        if let age = age { model.age = age }
        if let height = height { model.height = height }
        if let weight = weight { model.weight = weight }
        if let nickname = nickname { model.nickname = nickname }
    }

    func save(completion: @escaping (Bool) -> Void) {
        usecase.editUserInfo(model: model) { (isSaved) in
            completion(isSaved)
        }
    }
}

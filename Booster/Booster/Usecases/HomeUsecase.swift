//
//  HomeUsecase.swift
//  Booster
//
//  Created by hiju on 2021/11/14.
//
import Foundation
import HealthKit

import RxSwift

final class HomeUsecase {
    private let disposeBag = DisposeBag()

    func fetchHourlyStepCountsData() -> Single<StepStatisticsCollection> {
        return Single.create { [weak self] single in
            let anchorDate = Calendar.current.startOfDay(for: Date())
            guard let self = self,
                  let stepCountSampleType = HKSampleType.quantityType(forIdentifier: .stepCount),
                  let endDate = Calendar.current.date(byAdding: .hour,
                                                      value: 23,
                                                      to: anchorDate)
            else { return Disposables.create() }

            let predicate = HKQuery.predicateForSamples(withStart: anchorDate,
                                                        end: endDate,
                                                        options: .strictStartDate)

            let observable = HealthKitManager.shared.requestStatisticsCollectionQuery(type: stepCountSampleType,
                                                                       predicate: predicate,
                                                                       interval: DateComponents(hour: 1),
                                                                       anchorDate: anchorDate)

            observable.subscribe { hkStatisticsCollection in
                guard case let .success(hkStatisticsCollection) = hkStatisticsCollection
                else { return }

                var stepStatisticsCollection = StepStatisticsCollection()

                hkStatisticsCollection.enumerateStatistics(from: anchorDate,
                                                           to: endDate,
                                                           with: { hkstatistics, _ in

                    let step = Int(hkstatistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    let date = hkstatistics.startDate
                    let stepStatistics = self.configureStepStatistics(step: step, date: date)
                    stepStatisticsCollection.append(stepStatistics)
                })

                single(.success(stepStatisticsCollection))
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func fetchTodayTotalData(type: HKQuantityTypeIdentifier) -> Single<HKStatistics?> {
        return Single.create { [weak self] single in
            guard let self = self,
                  let sampleType = HKSampleType.quantityType(forIdentifier: type)
            else { return Disposables.create() }

            let now = Date()
            let start = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: start,
                                                        end: now,
                                                        options: .strictStartDate)

            let observable = HealthKitManager.shared.requestStatisticsQuery(type: sampleType, predicate: predicate)
            observable.subscribe { hkStatistics in
                single(.success(hkStatistics))
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
    
    func fetchGoalData() -> Single<Int?> {
        return Single.create { [weak self] single in
            guard let self = self
            else { return Disposables.create() }
            
            return CoreDataManager.shared.fetch()
                .map { [weak self] (userOfCoreData: [User]) -> UserInfo in
                    var userInfo = UserInfo()
                    
                    if let userModel = userOfCoreData.first,
                       let convertToUserModel = self?.convertToUserInfoFrom(user: userModel) {
                        userInfo = convertToUserModel
                    }
                    return userInfo
                }
                .subscribe(onSuccess: { result in
                    single(.success(result.goal))
                })
        }
    }
    
    private func configureStepStatistics(step: Int, date: Date) -> StepStatistics {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "H"

        let string = dateFormatter.string(from: date)

        return StepStatistics(step: step, abbreviatedDateString: string)
    }
    
    private func convertToUserInfoFrom(user: User) -> UserInfo? {
        if let nickname = user.nickname,
           let gender = user.gender {
            let userInfo = UserInfo(age: Int(user.age),
                                    nickname: nickname,
                                    gender: gender,
                                    height: Int(user.height),
                                    weight: Int(user.weight),
                                    goal: Int(user.goal))
            return userInfo
        }
        return nil
    }
}

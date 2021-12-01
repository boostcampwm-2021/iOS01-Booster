import Foundation
import RxSwift
import RxRelay

typealias TrackingError = TrackingProgressUsecase.TrackingError

final class TrackingProgressUsecase {
    enum TrackingError: Error, Equatable {
        case modelError
        case error(Error)

        static func == (lhs: TrackingProgressUsecase.TrackingError, rhs: TrackingProgressUsecase.TrackingError) -> Bool {
            return lhs.localizedDescription == lhs.localizedDescription
        }
    }

    let disposeBag = DisposeBag()

    func save(model: TrackingModel) -> Single<Void> {
        let entity = "Tracking"
        guard let coordinates = try? NSKeyedArchiver.archivedData(withRootObject: model.coordinates.all, requiringSecureCoding: false),
              let milestones = try? NSKeyedArchiver.archivedData(withRootObject: model.milestones.all, requiringSecureCoding: false),
              let endDate = model.endDate,
              let distance = Double(String(format: "%.2f", model.distance / 1000))
        else {
            return Single.create { single in
                single(.failure(TrackingError.modelError))
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

        return CoreDataManager.shared.save(attributes: value, type: entity)
    }

    func save(count: Double, start: Date, end: Date, quantity: HealthQuantityType, unit: HealthUnit) {
        HealthKitManager.shared.save(count: count, start: start, end: end, quantity: quantity, unit: unit)
    }

    func fetch() -> Single<UserInfo> {
        return CoreDataManager.shared.fetch()
            .map { (value: [User]) in
                var userInfo = UserInfo()

                if let user = value.first,
                    let info = self.convert(user: user) {
                    userInfo = info
                }

                return userInfo
            }
    }

    private func convert(user: User) -> UserInfo? {
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

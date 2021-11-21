import Foundation
import RxSwift

typealias TrackingError = TrackingProgressUsecase.TrackingError

final class TrackingProgressUsecase {
    enum TrackingError: Error, Equatable {
        case modelError
        case error(Error)

        static func == (lhs: TrackingProgressUsecase.TrackingError, rhs: TrackingProgressUsecase.TrackingError) -> Bool {
            return lhs.localizedDescription == lhs.localizedDescription
        }
    }

    private enum CoreDataKeys {
        static let startDate: String = "startDate"
        static let endDate: String = "endDate"
        static let steps: String = "steps"
        static let calories: String = "calories"
        static let seconds: String = "seconds"
        static let distance: String = "distance"
        static let coordinates: String = "coordinates"
        static let milestones: String = "milestones"
        static let title: String = "title"
        static let content: String = "content"
        static let imageData: String = "imageData"
    }

    let disposeBag = DisposeBag()

    func save(model: TrackingModel, completion handler: @escaping (TrackingError?) -> Void) {
        let entity = "Tracking"
        guard let coordinates = try? NSKeyedArchiver.archivedData(withRootObject: model.coordinates, requiringSecureCoding: false),
              let milestones = try? NSKeyedArchiver.archivedData(withRootObject: model.milestones, requiringSecureCoding: false),
              let endDate = model.endDate
        else {
            handler(.modelError)
            return
        }
        let value: [String: Any] = [
            CoreDataKeys.startDate: model.startDate,
            CoreDataKeys.endDate: endDate,
            CoreDataKeys.steps: model.steps,
            CoreDataKeys.calories: model.calories,
            CoreDataKeys.seconds: model.seconds,
            CoreDataKeys.distance: model.distance,
            CoreDataKeys.coordinates: coordinates,
            CoreDataKeys.milestones: milestones,
            CoreDataKeys.title: model.title,
            CoreDataKeys.content: model.content,
            CoreDataKeys.imageData: model.imageData
        ]

        CoreDataManager.shared.save(value: value, type: entity) { response in
            switch response {
            case .success:
                handler(nil)
            case .failure(let error):
                handler(.error(error))
            }
        }
    }

    func save(count: Double, start: Date, end: Date, quantity: HealthQuantityType, unit: HealthUnit) {
        HealthStoreManager.shared.save(count: count, start: start, end: end, quantity: quantity, unit: unit)
    }

    func fetch() -> Observable<UserInfo> {
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
                                    weight: Int(user.weight))
            return userInfo
        }
        return nil
    }
}

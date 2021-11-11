import Foundation

typealias TrackingError = TrackingProgressUsecase.TrackingError

final class TrackingProgressUsecase {
    enum TrackingError: Error {
        case countError
        case modelError
        case error(Error)
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

    private var errors: Observable<[TrackingError?]>
    private var handler: ((TrackingError?) -> Void)?
    private let entity: String
    private let repository: RepositoryManager

    init() {
        errors = Observable([])
        entity = "Tracking"
        repository = RepositoryManager()
        errors.bind { values in
            guard let handler = self.handler
            else { return }

            if values.count != 4 {
                handler(.countError)
                return
            }

            if let value = values.filter({ $0 != nil }).first, let error = value {
                handler(error)
                return
            }

            handler(nil)
        }
    }

    func bind(handler: @escaping (TrackingError?) -> Void) {
        self.handler = handler
    }

    func save(model: TrackingModel) {
        guard let coordinates = try? NSKeyedArchiver.archivedData(withRootObject: model.coordinates, requiringSecureCoding: false),
              let milestones = try? NSKeyedArchiver.archivedData(withRootObject: model.milestones, requiringSecureCoding: false),
              let endDate = model.endDate
        else {
            errors.value.append(.modelError)
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

        repository.save(value: value, type: entity) { [weak self] response in
            guard let self = self
            else { return }

            switch response {
            case .success:
                self.errors.value.append(nil)
            case .failure(let error):
                self.errors.value.append(.error(error))
            }
        }
    }

    func save(count: Double,
              start: Date,
              end: Date,
              quantity: HealthQuantityType,
              unit: HealthUnit) {
        HealthStoreManager.shared.save(count: count,
                                       start: start,
                                       end: end,
                                       quantity: quantity,
                                       unit: unit) { [weak self] error in
            guard let error = error
            else {
                self?.errors.value.append(nil)
                return
            }
            self?.errors.value.append(.error(error))
        }
    }
}

import Foundation

final class TrackingProgressUsecase {
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
    }

    private let entity: String
    private let repository: RepositoryManager

    init() {
        entity = "Tracking"
        repository = RepositoryManager()
    }

    func save(model: TrackingModel, completion handler: @escaping (String) -> Void) {
        guard let coordinates = try? NSKeyedArchiver.archivedData(withRootObject: model.coordinates, requiringSecureCoding: false),
              let milestones = try? NSKeyedArchiver.archivedData(withRootObject: model.milestones, requiringSecureCoding: false) else {
                  handler("archiving error")
                  return
              }
        let value: [String: Any] = [
            CoreDataKeys.startDate: model.startDate,
            CoreDataKeys.endDate: model.endDate,
            CoreDataKeys.steps: model.steps,
            CoreDataKeys.calories: model.calories,
            CoreDataKeys.seconds: model.seconds,
            CoreDataKeys.distance: model.distance,
            CoreDataKeys.coordinates: coordinates,
            CoreDataKeys.milestones: milestones,
            CoreDataKeys.title: model.title,
            CoreDataKeys.content: model.content
        ]
        print(value)
        repository.save(value: value, type: entity) { response in
            switch response {
            case .success:
                handler("success")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

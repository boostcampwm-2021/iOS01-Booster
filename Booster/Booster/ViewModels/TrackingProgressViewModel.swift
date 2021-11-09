import Foundation
import CoreLocation

final class TrackingProgressViewModel {
    enum TrackingState {
        case start
        case pause
        case end
    }

    private let trackingUsecase: TrackingProgressUsecase
    private(set) var trackingModel: Observable<TrackingModel>
    private(set) var milestones: Observable<[MileStone]>
    private(set) var user: UserInfo
    private(set) var state: TrackingState

    init(trackingModel: TrackingModel = TrackingModel(), user: UserInfo = UserInfo()) {
        trackingUsecase = TrackingProgressUsecase()
        self.trackingModel = Observable(trackingModel)
        self.milestones = Observable([MileStone]())
        self.user = user
        state = .start
    }

    func append(coordinate: Coordinate) {
        trackingModel.value.coordinates.append(coordinate)
    }

    func append(milestone: MileStone) {
        milestones.value.append(milestone)
    }

    func appends(coordinates: [Coordinate]) {
        trackingModel.value.coordinates.append(contentsOf: coordinates)
    }

    func appends(milestones: [MileStone]) {
        trackingModel.value.milestones.append(contentsOf: milestones)
    }

    func recordEnd() {
        trackingModel.value.endDate = Date()
        trackingModel.value.milestones = milestones.value
        state = .end
    }

    func write(title: String) {
        trackingModel.value.title = title
    }

    func write(content: String) {
        trackingModel.value.content = content
    }

    func update(seconds: Int) {
        trackingModel.value.seconds = seconds
    }

    func update(steps: Int) {
        trackingModel.value.steps += steps
    }

    func update(distance: Double) {
        trackingModel.value.distance += distance
    }

    func update(calroies: Int) {
        trackingModel.value.calories = calroies
    }

    func toggle() {
        state = state == .start ? .pause : .start
        if state == .pause { trackingModel.value.coordinates.append(Coordinate(latitude: nil, longitude: nil))}
    }

    func latestCoordinate() -> Coordinate? {
        guard let latestCoordinate = trackingModel.value.coordinates.last else { return nil }
        return latestCoordinate
    }

    func startCoordinate() -> Coordinate? {
        guard let startCoordinate = trackingModel.value.coordinates.first else { return nil }
        return startCoordinate
    }

    func save(completion handler: @escaping (TrackingError?) -> Void) {
        trackingUsecase.bind(handler: handler)
        trackingUsecase.save(model: trackingModel.value)
        trackingUsecase.save(count: Double(trackingModel.value.steps),
                             start: trackingModel.value.startDate,
                             end: trackingModel.value.endDate ?? Date(),
                             quantity: .steps,
                             unit: .count)
        trackingUsecase.save(count: trackingModel.value.distance,
                             start: trackingModel.value.startDate,
                             end: trackingModel.value.endDate ?? Date(),
                             quantity: .runing,
                             unit: .kilometer)
        trackingUsecase.save(count: Double(trackingModel.value.calories),
                             start: trackingModel.value.startDate,
                             end: trackingModel.value.endDate ?? Date(),
                             quantity: .energy,
                             unit: .calorie)
    }

    func mileStone(at coordinate: Coordinate) -> MileStone? {
        let target = milestones.value.first(where: { (value) in
            return value.coordinate == coordinate
        })

        return target
    }

    func isMileStoneExistAt(latitude: Double, longitude: Double) -> Bool {
        let coordinate = Coordinate(latitude: latitude, longitude: longitude)
        for value in milestones.value {
            if value.coordinate == coordinate { return true }
        }

        return false
    }

    func remove(of mileStone: MileStone) -> MileStone? {
        guard let index = milestones.value.firstIndex(of: mileStone) else { return nil }
        return milestones.value.remove(at: index)
    }
}

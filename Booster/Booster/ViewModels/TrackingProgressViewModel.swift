import Foundation

final class TrackingProgressViewModel {
    enum TrackingState {
        case start
        case pause
        case end
    }

    private(set) var trackingModel: Observable<TrackingModel>
    private(set) var user: UserInfo
    private(set) var state: Observable<TrackingState>

    init(trackingModel: TrackingModel = TrackingModel(), user: UserInfo = UserInfo()) {
        self.trackingModel = Observable(trackingModel)
        self.user = user
        self.state = Observable(.start)
    }

    func append(coordinate: Coordinate) {
        trackingModel.value.coordinates.append(coordinate)
    }

    func append(milestone: MileStone) {
        trackingModel.value.milestones.append(milestone)
    }

    func appends(coordinates: [Coordinate]) {
        trackingModel.value.coordinates.append(contentsOf: coordinates)
    }

    func appends(milestones: [MileStone]) {
        trackingModel.value.milestones.append(contentsOf: milestones)
    }

    func recordEnd() {
        trackingModel.value.endDate = Date()
        state.value = .end
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
        trackingModel.value.steps = steps
    }

    func update(distance: Double) {
        trackingModel.value.distance += distance
    }

    func update(calroies: Int) {
        trackingModel.value.calories = calroies
    }

    func toggle() {
        state.value = state.value == .start ? .pause : .start
    }

    func latestCoordinate() -> Coordinate? {
        guard let latestCoordinate = trackingModel.value.coordinates.last else { return nil }
        return latestCoordinate
    }
}

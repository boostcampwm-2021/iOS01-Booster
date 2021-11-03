import Foundation

final class TrackingProgressViewModel {
    enum TrackingState {
        case start
        case pause
        case end
    }

    private(set) var trackingModel: TrackingModel
    private(set) var user: UserInfo
    private(set) var state: TrackingState

    init(trackingModel: TrackingModel = TrackingModel(), user: UserInfo = UserInfo()) {
        self.trackingModel = trackingModel
        self.user = user
        self.state = .start
    }

    func append(coordinate: Coordinate) {
        trackingModel.coordinates.append(coordinate)
    }

    func append(milestone: MileStone) {
        trackingModel.milestones.append(milestone)
    }

    func appends(coordinates: [Coordinate]) {
        trackingModel.coordinates.append(contentsOf: coordinates)
    }

    func appends(milestones: [MileStone]) {
        trackingModel.milestones.append(contentsOf: milestones)
    }

    func recordEnd() {
        trackingModel.endDate = Date()
        state = .end
    }

    func write(title: String) {
        trackingModel.title = title
    }

    func write(content: String) {
        trackingModel.content = content
    }

    func update(seconds: Int) {
        trackingModel.seconds = seconds
    }

    func update(steps: Int) {
        trackingModel.steps = steps
    }

    func update(distance: Double) {
        trackingModel.distance += distance
    }

    func toggle() {
        state = state == .start ? .pause : .start
    }
    
    func latestCoordinate() -> Coordinate? {
        guard let latestCoordinate = trackingModel.coordinates.last else { return nil }
        return latestCoordinate
    }
}

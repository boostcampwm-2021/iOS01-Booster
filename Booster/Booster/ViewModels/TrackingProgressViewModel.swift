import Foundation

final class TrackingProgressViewModel {
    private(set) var trackingModel: TrackingModel
    private(set) var user: User
    private(set) var state: TrackingState

    init(trackingModel: TrackingModel = TrackingModel(), user: User) {
        self.trackingModel = trackingModel
        self.user = user
        self.state = .start
    }

    func append(coordinate: Coordinate?) {
        trackingModel.coordinates.append(coordinate)
    }

    func append(mileStone: MileStone) {
        trackingModel.milestones.append(mileStone)
    }

    func appends(coordinates: [Coordinate?]) {

    }

    func appends(mileStones: [MileStone]) {

    }

    func recordEnd() {

    }

    func write(title: String) {

    }

    func write(content: String) {

    }

    func update(seconds: Int) {

    }

    func update(steps: Int) {

    }

    func update(distance: Double) {

    }

    func toggle() {
        if state == .start {
            state = .pause
            trackingModel.coordinates.append(nil)
        } else if state == .pause {
            state = .start
        }
    }

    func latestCoordinate() -> Coordinate? {
        guard let latestCoordinate = trackingModel.coordinates.last else { return nil }
        return latestCoordinate
    }
}

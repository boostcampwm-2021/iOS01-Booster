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
        self.milestones.value.append(contentsOf: milestones)
    }

    func recordEnd() {
        trackingModel.value.endDate = Date()
        convert()
        trackingModel.value.milestones = milestones.value
        state = .end
    }

    func write(title: String) {
        trackingModel.value.title = title
    }

    func write(content: String) {
        trackingModel.value.content = content
    }

    func update(imageData: Data) {
        trackingModel.value.imageData = imageData
    }

    func update(seconds: Int) {
        let velocity: Double = trackingModel.value.distance/Double(seconds)
        let minute = Double(seconds) / 60
        let height: Double = Double(user.height)/100 == 0 ? 1 : Double(user.height)/100
        let calroiesPerMinute = (0.035*Double(user.weight))+((pow(velocity, 2)/height)*0.029*Double(user.weight))
        let calroies: Int = Int(minute*calroiesPerMinute)

        trackingModel.value.seconds = seconds
        trackingModel.value.calories = calroies
    }

    func update(steps: Int) {
        trackingModel.value.steps += steps
    }

    func update(distance: Double) {
        trackingModel.value.distance += distance
    }

    func toggle() {
        state = state == .start ? .pause : .start
        if state == .pause { trackingModel.value.coordinates.append(Coordinate(latitude: nil, longitude: nil))}
    }

    func coordinates() -> [Coordinate] {
        return trackingModel.value.coordinates
    }

    func latestCoordinate() -> Coordinate? {
        guard let latestCoordinate = trackingModel.value.coordinates.last
        else { return nil }

        return latestCoordinate
    }

    func startCoordinate() -> Coordinate? {
        guard let startCoordinate = trackingModel.value.coordinates.first
        else { return nil }

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

    func centerCoordinateOfPath() -> CLLocationCoordinate2D? {
        guard let startCoordinate = startCoordinate(),
              let startLat = startCoordinate.latitude,
              let startLong = startCoordinate.longitude
        else { return nil }

        var maxLat: Double = startLat
        var minLat: Double = startLat
        var maxLong: Double = startLong
        var minLong: Double = startLong

        trackingModel.value.coordinates.forEach { (coordinate) in
            guard let latValue = coordinate.latitude,
                  let longValue = coordinate.longitude
            else { return }

            if maxLat < latValue { maxLat = latValue } else if minLat > latValue { minLat = latValue }

            if maxLong < longValue { maxLong = longValue } else if minLong > longValue { minLong = longValue}
        }

        let midLat = (maxLat + minLat) / 2.0
        let midLong = (maxLong + minLong) / 2.0

        return CLLocationCoordinate2D(latitude: midLat, longitude: midLong)
    }

    func remove(of mileStone: MileStone) -> MileStone? {
        guard let index = milestones.value.firstIndex(of: mileStone)
        else { return nil }

        return milestones.value.remove(at: index)
    }

    func distance() -> Double {
        return trackingModel.value.distance
    }

    private func convert() {
        let meter = trackingModel.value.distance

        if let kilometer = Double(String(format: "%.2f", meter/1000)) {
            trackingModel.value.distance = kilometer
        }
    }
}

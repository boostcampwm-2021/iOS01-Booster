import Foundation

struct TrackingModel {
    let startDate: Date
    var endDate: Date?
    var steps: Int
    var calories: Int
    var seconds: Int
    var distance: Double
    var coordinates: [Coordinate?]
    var milestones: [MileStone]
    var title: String?
    var content: String?

    init() {
        self.startDate = Date()
        self.steps = 0
        self.calories = 0
        self.seconds = 0
        self.distance = 0
        self.coordinates = []
        self.milestones = []
    }
}

import Foundation

struct TrackingModel {
    var startDate: Date
    var endDate: Date?
    var steps: Int
    var calories: Int
    var seconds: Int
    var distance: Double
    var coordinates: [Coordinate]
    var milestones: [MileStone]
    var title: String
    var content: String

    init(startDate: Date = Date(),
         steps: Int = 0,
         calories: Int = 0,
         seconds: Int = 0,
         distance: Double = 0,
         coordinates: [Coordinate] = [],
         milestones: [MileStone] = [],
         title: String = "",
         content: String = "") {
        self.startDate = startDate
        self.steps = steps
        self.calories = calories
        self.seconds = seconds
        self.distance = distance
        self.coordinates = coordinates
        self.milestones = milestones
        self.title = title
        self.content = content
    }
}

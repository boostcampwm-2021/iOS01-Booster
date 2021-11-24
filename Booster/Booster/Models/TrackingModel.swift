import Foundation

struct TrackingModel {
    var startDate: Date
    var endDate: Date?
    var steps: Int
    var calories: Int
    var seconds: Int
    var distance: Double
    var coordinates: [Coordinate]
    var milestones: [Milestone]
    var title: String
    var content: String
    var imageData: Data
    var address: String

    init(startDate: Date = Date(),
         endDate: Date? = nil,
         steps: Int = 0,
         calories: Int = 0,
         seconds: Int = 0,
         distance: Double = 0,
         coordinates: [Coordinate] = [],
         milestones: [Milestone] = [],
         title: String = "",
         content: String = "",
         imageData: Data = Data(),
         address: String = "") {
        self.startDate = startDate
        self.steps = steps
        self.calories = calories
        self.seconds = seconds
        self.distance = distance
        self.coordinates = coordinates
        self.milestones = milestones
        self.title = title
        self.content = content
        self.imageData = imageData
        self.endDate = endDate
        self.address = address
    }
}

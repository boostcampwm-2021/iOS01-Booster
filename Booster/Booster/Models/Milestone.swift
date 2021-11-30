import Foundation

final class Milestones {
    private var milestones: [Milestone]

    var first: Milestone? {
        return milestones.first
    }
    var last: Milestone? {
        return milestones.last
    }
    var count: Int {
        return milestones.count
    }
    var all: [Milestone] {
        return milestones
    }

    subscript(index: Int) -> Milestone? {
        if (0..<milestones.count).contains(index) { return milestones[index] }
        else { return nil }
    }

    init() {
        self.milestones = []
    }

    init(milestone: Milestone) {
        self.milestones = [milestone]
    }

    init(milestones: [Milestone]) {
        self.milestones = milestones
    }

    func append(_ milestone: Milestone) {
        milestones.append(milestone)
    }

    func appends(_ newMilestone: [Milestone]) {
        milestones += newMilestone
    }

    func remove(of milestone: Milestone) -> Milestone? {
        guard let index = firstIndex(of: milestone)
        else { return nil }

        return milestones.remove(at: index)
    }

    func firstIndex(of targetMilestone: Milestone) -> Int? {
        return milestones.enumerated().first(where: { $0.element == targetMilestone })?.offset
    }

    func milestone(at coordinate: Coordinate) -> Milestone? {
        return milestones.first(where: { milestone in
            milestone.coordinate == coordinate
        })
    }
}

final class Milestone: NSObject, NSCoding {
    var coordinate: Coordinate
    var imageData: Data

    init(latitude: Double = 0, longitude: Double = 0, imageData: Data = Data()) {
        self.coordinate = Coordinate(latitude: latitude, longitude: longitude)
        self.imageData = imageData
    }

    public func encode(with coder: NSCoder) {
        coder.encode(coordinate, forKey: "coordinate")
        coder.encode(imageData, forKey: "imageData")
    }

    public init?(coder: NSCoder) {
        coordinate = Coordinate(latitude: 0, longitude: 0)
        imageData = Data()
        if let coordinate = coder.decodeObject(forKey: "coordinate") as? Coordinate,
           let data = coder.decodeObject(forKey: "imageData") as? Data {
            self.coordinate = coordinate
            imageData = data
        }
    }
}

extension Milestone {
    public static func ==(lhs: Milestone, rhs: Milestone) -> Bool {
        return lhs.coordinate == rhs.coordinate
    }
}

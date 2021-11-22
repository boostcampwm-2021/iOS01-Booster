import Foundation

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

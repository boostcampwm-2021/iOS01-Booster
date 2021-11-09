import Foundation

public final class MileStone: NSObject, NSCoding {
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
        if let coord = coder.decodeObject(forKey: "coordinate") as? Coordinate,
              let data = coder.decodeObject(forKey: "imageData") as? Data {
            coordinate = coord
            imageData = data
        }
    }
}

extension MileStone {
    public static func ==(lhs: MileStone, rhs: MileStone) -> Bool {
        return lhs.coordinate == rhs.coordinate
    }
}

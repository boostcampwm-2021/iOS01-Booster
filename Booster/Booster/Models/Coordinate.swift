import Foundation

final class Coordinate: NSObject, NSCoding {
    var latitude: Double?
    var longitude: Double?

    init(latitude: Double? = nil, longitude: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public func encode(with coder: NSCoder) {
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
    }

    public init?(coder: NSCoder) {
        super.init()
        if let latitude = coder.decodeObject(forKey: "latitude") as? Double {
            self.latitude = latitude
        }

        if let longitude = coder.decodeObject(forKey: "longitude") as? Double {
            self.longitude = longitude
        }
    }
}

extension Coordinate {
    public static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
        guard let lhsLat = lhs.latitude,
              let lhsLong = lhs.longitude,
              let rhsLat = rhs.latitude,
              let rhsLong = rhs.longitude
        else { return false }

        return (lhsLat == rhsLat) && (lhsLong == rhsLong)
    }
}

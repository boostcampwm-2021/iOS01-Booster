import Foundation

public final class Coordinate: NSObject, NSCoding {
    let latitude: Double?
    let longitude: Double?

    init(latitude: Double? = nil, longitude: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public func encode(with coder: NSCoder) {
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
    }

    public init?(coder: NSCoder) {
        guard let lat = coder.decodeObject(forKey: "latitude") as? Double,
              let lng = coder.decodeObject(forKey: "longitude") as? Double
        else {
            return nil
        }
        latitude = lat
        longitude = lng
    }
}

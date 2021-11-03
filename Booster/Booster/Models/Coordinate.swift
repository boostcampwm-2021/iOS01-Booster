import Foundation

public final class Coordinate: NSObject {
    let latitude: Double?
    let longitude: Double?

    init(latitude: Double? = nil, longitude: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

import Foundation

public final class MileStone: NSObject {
    let coordinate: Coordinate
    let imageData: Data

    init(latitude: Double = 0, longitude: Double = 0, imageData: Data = Data()) {
        self.coordinate = Coordinate(latitude: latitude, longitude: longitude)
        self.imageData = imageData
    }
}

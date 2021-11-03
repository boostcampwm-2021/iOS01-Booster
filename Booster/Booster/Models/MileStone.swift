import Foundation

class MileStone {
    let coordinate: Coordinate
    let imageData: Data

    init(latitude: Double, longitude: Double, imageData: Data) {
        self.coordinate = Coordinate(latitude: latitude, longitude: longitude)
        self.imageData = imageData
    }
}

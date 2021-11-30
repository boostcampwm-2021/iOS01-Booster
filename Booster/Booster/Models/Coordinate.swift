import Foundation

final class Coordinates {
    private var coordinates: [Coordinate]

    var first: Coordinate? {
        return coordinates.first
    }
    var last: Coordinate? {
        return coordinates.last
    }
    var count: Int {
        return coordinates.count
    }
    var all: [Coordinate] {
        return coordinates
    }

    subscript(index: Int) -> Coordinate? {
        if (0..<coordinates.count).contains(index) { return coordinates[index] }
        else { return nil }
    }

    init() {
        self.coordinates = []
    }

    init(coordinates: [Coordinate]) {
        self.coordinates = coordinates
    }

    init(coordinate: Coordinate) {
        self.coordinates = [coordinate]
    }

    func append(_ coordinate: Coordinate) {
        coordinates.append(coordinate)
    }

    func appends(_ newCoordinates: [Coordinate]) {
        coordinates += newCoordinates
    }

    func center() -> Coordinate {
        let ((minLatitude, maxLatitude), (minLongitude, maxLongitude)) = coordinates
            .filter { $0.latitude != nil && $0.longitude != nil }
            .reduce(((90.0, -90.0), (180.0, -180.0))) { next, current in
            ((min(current.latitude!, next.0.0),
              max(current.latitude!, next.0.1)),
             (min(current.longitude!, next.1.0),
              max(current.longitude!, next.1.1)))
        }
        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2

        return Coordinate(latitude: centerLatitude, longitude: centerLongitude)
    }

    func indexRatio(_ coordinate: Coordinate) -> Double? {
        guard let index = coordinates.enumerated().filter({ $0.element == coordinate }).first?.offset
        else { return  nil }

        return Double(index) / Double(coordinates.count)
    }

    func firstIndex(of targetCoordinate: Coordinate) -> Int? {
        return coordinates.enumerated().first(where: { $0.element == targetCoordinate })?.offset
    }
}

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

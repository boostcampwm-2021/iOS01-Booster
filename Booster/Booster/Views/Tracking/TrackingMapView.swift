import UIKit
import MapKit

class TrackingMapView: BoosterMapView {
    private var overlay: MKOverlay = MKCircle()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    func removeMilestoneAnnotation(of mileStone: Milestone) -> Bool {
        guard let annotation = annotations.first(where: {
            let coordinate = Coordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)

            return coordinate == mileStone.coordinate
        })
        else { return false }

        removeAnnotation(annotation)

        return true
    }

    func snapShotImageOfPath(backgroundColor color: UIColor = .white,
                             coordinates: Coordinates,
                             center: CLLocationCoordinate2D,
                             range: Double,
                             completion: @escaping(UIImage?) -> Void) {
        let dotSize = CGSize(width: 16, height: 16)
        let options = MKMapSnapshotter.Options()
        let range = range + 50

        options.size = CGSize(width: 250, height: 250)
        options.region = MKCoordinateRegion(center: center,
                                            latitudinalMeters: range,
                                            longitudinalMeters: range)

        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start { [weak self] (snapshot, _) in
            guard let snapshot = snapshot
            else { return }

            let image = snapshot.image
            let pathLineWidth: CGFloat = 6

            UIGraphicsBeginImageContext(image.size)
            color.setFill()
            UIRectFill(CGRect(origin: .zero, size: image.size))

            guard let context = UIGraphicsGetCurrentContext()
            else { return }

            context.setLineWidth(pathLineWidth)
            context.setStrokeColor(UIColor.boosterOrange.cgColor)
            context.setLineCap(.round)

            var prevCoordinate: Coordinate? = coordinates.first
            guard let startLatitude = prevCoordinate?.latitude,
                  let startLongitude = prevCoordinate?.longitude
            else { return }
            var endCoordinate
            = Coordinate(latitude: startLatitude, longitude: startLongitude)

            var point = snapshot.point(for: CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude))
            point.x -= dotSize.width / 2.0
            point.y -= dotSize.height / 2.0
            UIColor.boosterBackground.setFill()
            context.addEllipse(in: CGRect(origin: point, size: dotSize))
            context.drawPath(using: .fill)

            for coordinate in coordinates.all {
                if let prevLatitude = prevCoordinate?.latitude,
                   let prevLongitude = prevCoordinate?.longitude {
                    context.move(to: snapshot.point(for: CLLocationCoordinate2D(latitude: prevLatitude, longitude: prevLongitude)))
                } else {
                    prevCoordinate = coordinate
                    continue
                }

                if let currentLatitude = coordinate.latitude,
                   let currentLongitude = coordinate.longitude {
                    context.addLine(to: snapshot.point(for: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)))
                    context.move(to: snapshot.point(for: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)))
                }

                prevCoordinate = coordinate
                if coordinate.latitude != nil && coordinate.longitude != nil { endCoordinate = coordinate }

                if let ratio = coordinates.indexRatio(coordinate),
                   let gradientColor = self?.gradientColorOfCoordinate(indexRatio: ratio,
                                                                       from: .boosterBackground,
                                                                       to: .boosterOrange) {
                    gradientColor.set()
                    context.strokePath()
                }
            }

            if let endLatitude = endCoordinate.latitude,
               let endLongitude = endCoordinate.longitude {
                var point = snapshot.point(for: CLLocationCoordinate2D(latitude: endLatitude, longitude: endLongitude))
                point.y -= dotSize.height / 2.0
                context.addEllipse(in: CGRect(origin: point, size: dotSize))
                context.drawPath(using: .fill)
            }

            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            completion(resultImage)
        }
    }

    private func configure() {
        setUserTrackingMode(.follow, animated: true)
        mapType = .standard
        showsUserLocation = true
        userLocation.title = ""
        tintColor = .boosterOrange
    }
}

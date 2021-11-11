import UIKit
import MapKit

class TrackingMapView: MKMapView {
    private var overlay: MKOverlay = MKCircle()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    func addMileStoneAnnotation(on coordinate: CLLocationCoordinate2D) -> Bool {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "milestone"
        addAnnotation(annotation)

        return true
    }

    func addMileStoneAnnotation(latitude lat: CLLocationDegrees, longitude long: CLLocationDegrees) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = "milestone"

        addAnnotation(annotation)
    }

    func removeMileStoneAnnotation(of mileStone: MileStone) -> Bool {
        guard let annotation = annotations.first(where: {
            let coordinate = Coordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)

            return coordinate == mileStone.coordinate
        })
        else { return false }

        removeAnnotation(annotation)

        return true
    }

    func setRegion(to location: CLLocation) {
        let regionRadius: CLLocationDistance = 100
        let coordRegion = MKCoordinateRegion(center: location.coordinate,
                                             latitudinalMeters: regionRadius*2,
                                             longitudinalMeters: regionRadius*2)
        setRegion(coordRegion, animated: false)
    }

    func drawPath(from prevCoordinate: CLLocationCoordinate2D?, to currentCoordinate: CLLocationCoordinate2D?) {
        guard let currentCoordinate = currentCoordinate,
              let prevCoordinate = prevCoordinate
        else { return }

        let points: [CLLocationCoordinate2D] = [prevCoordinate, currentCoordinate]
        let line = MKPolyline(coordinates: points, count: points.count)
        line.title = "path"

        addOverlay(line)
    }

    func updateUserLocationOverlay(location: CLLocation?) {
        guard let current = location else { return }

        let regionRadius: CLLocationDistance = 100
        let overlayRadius: CLLocationDistance = 20
        let coordRegion = MKCoordinateRegion(center: current.coordinate,
                                             latitudinalMeters: regionRadius * 2,
                                             longitudinalMeters: regionRadius * 2)

        removeOverlay(overlay)

        overlay = MKCircle(center: current.coordinate, radius: overlayRadius)
        setRegion(coordRegion, animated: true)

        addOverlay(overlay)
    }

    func snapShotImageOfPath(backgroundColor color: UIColor = .white,
                             coordinates: [Coordinate],
                             center: CLLocationCoordinate2D,
                             completion: @escaping(UIImage?) -> Void) {
        let dotSize = CGSize(width: 16, height: 16)
        let options = MKMapSnapshotter.Options()
        options.size = CGSize(width: 250, height: 250)
        options.region = MKCoordinateRegion(center: center,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)

        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start { [weak self] (snapshot, _) in
            guard let snapshot = snapshot else { return }
            let image = snapshot.image
            let pathLineWidth: CGFloat = 6

            UIGraphicsBeginImageContext(image.size)
            color.setFill()
            UIRectFill(CGRect(origin: .zero, size: image.size))

            guard let context = UIGraphicsGetCurrentContext() else { return }
            context.setLineWidth(pathLineWidth)
            context.setStrokeColor(UIColor.boosterOrange.cgColor)

            var prevCoordinate: Coordinate? = self?.startCoordinate(coordinates: coordinates)
            guard let startLatitude = prevCoordinate?.latitude,
                  let startLongitude = prevCoordinate?.longitude
            else { return }

            var point = snapshot.point(for: CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude))
            point.x -= dotSize.width / 2.0
            point.y -= dotSize.height / 2.0
            UIColor.boosterBackground.setFill()
            context.addEllipse(in: CGRect(origin: point, size: dotSize))
            context.drawPath(using: .fill)

            for coordinate in coordinates {
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

                if let gradientColor = self?.gradientColorOfCoordinate(at: coordinate,
                                                                 coordinates: coordinates,
                                                                 from: .boosterBackground,
                                                                 to: .boosterOrange) {
                    gradientColor.set()
                    context.strokePath()
                }
            }

            if let endCoordinate = self?.endCoordinate(coordinates: coordinates),
               let endLatitude = endCoordinate.latitude,
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

    private func gradientColorOfCoordinate(at coordinate: Coordinate,
                                           coordinates: [Coordinate],
                                           from fromColor: UIColor,
                                           to toColor: UIColor) -> UIColor? {
        guard let indexOfTargetCoordinate = coordinates.firstIndex(of: coordinate) else { return nil }
        let percentOfPathProgress = Double(indexOfTargetCoordinate) / Double(coordinates.count)

        let red = fromColor.redValue + ((toColor.redValue - fromColor.redValue) * percentOfPathProgress)
        let green = fromColor.greenValue + ((toColor.greenValue - fromColor.greenValue) * percentOfPathProgress)
        let blue = fromColor.blueValue + ((toColor.blueValue - fromColor.blueValue) * percentOfPathProgress)

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    private func startCoordinate(coordinates: [Coordinate]) -> Coordinate? {
        for coordinate in coordinates {
            if coordinate.latitude != nil && coordinate.longitude != nil { return coordinate }
        }

        return nil
    }

    private func endCoordinate(coordinates: [Coordinate]) -> Coordinate? {
        for coordinate in coordinates.reversed() {
            if coordinate.latitude != nil && coordinate.longitude != nil { return coordinate }
        }

        return nil
    }
}

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
        addAnnotation(annotation)

        return true
    }

    func addMileStoneAnnotation(latitude lat: CLLocationDegrees, longitude long: CLLocationDegrees) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

        addAnnotation(annotation)
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

        addOverlay(line)
    }

    func updateUserLocationOverlay(location: CLLocation?) {
        guard let current = location else {
            return
        }

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

    private func configure() {
        setUserTrackingMode(.follow, animated: true)
        mapType = .standard
        showsUserLocation = true
    }
}

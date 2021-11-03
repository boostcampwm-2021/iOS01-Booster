import UIKit
import MapKit

class TrackingMapView: MKMapView {
    private var locationManager = CLLocationManager()
    private var overlay: MKOverlay = MKCircle()
    private var locationPath: [CLLocationCoordinate2D] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        locationAuth()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
        locationAuth()
    }

    func configure(location: CLLocation) {
        let regionRadius: CLLocationDistance = 100
        let coordRegion = MKCoordinateRegion(center: location.coordinate,
                                             latitudinalMeters: regionRadius*2,
                                             longitudinalMeters: regionRadius*2)
        setRegion(coordRegion, animated: false)
    }

    private func configure() {
        setUserTrackingMode(.follow, animated: true)
        mapType = .standard
        showsUserLocation = true
    }

    private func locationAuth() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        switch CLLocationManager.locationServicesEnabled() {
        case true:
            DispatchQueue.main.async { [weak self] in
                self?.locationManager.startUpdatingLocation()
            }
        case false:
            break
        }
    }
}

extension TrackingMapView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateUserLocationOverlay(location: locations.first)
        drawPath(to: locations.first?.coordinate)
    }

    private func drawPath(to currentCoordinate: CLLocationCoordinate2D?) {
        guard let currentCoordinate = currentCoordinate else { return }
        guard let prevCoordinate = locationPath.last else {
            locationPath.append(currentCoordinate)
            return
        }

        let points: [CLLocationCoordinate2D] = [prevCoordinate, currentCoordinate]
        let line = MKPolyline(coordinates: points, count: points.count)
        locationPath.append(currentCoordinate)

        addOverlay(line)
    }

    private func updateUserLocationOverlay(location: CLLocation?) {
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
}

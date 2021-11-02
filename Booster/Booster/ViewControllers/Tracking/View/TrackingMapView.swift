import Foundation
import UIKit
import MapKit

class TrackingMapView: MKMapView {
    private var locationManager = CLLocationManager()
    private var overlay: MKOverlay = MKCircle()
    private var locationPath: [CLLocationCoordinate2D?] = []
    private var isRunning: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        locationAuth()

        mapType = .standard
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
        locationAuth()
    }

    func start() {
        isRunning = true
    }

    func pause() {
        isRunning = false
        locationPath.append(nil)
    }

    func stop() {

    }

    func currentCoordinate() -> CLLocationCoordinate2D? {
        return locationPath.last ?? nil
    }

    func addMileStonePhoto() -> Bool {
        guard let currentPoint = currentCoordinate() else { return false }
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: currentPoint.latitude, longitude: currentPoint.longitude)
        addAnnotation(annotation)

        return true
    }

    func addMileStonePhoto(latitude lat: CLLocationDegrees, longitude long: CLLocationDegrees) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

        addAnnotation(annotation)
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

    private func drawPath(to currentCoordinate: CLLocationCoordinate2D?) {
        guard let currentCoordinate = currentCoordinate else { return }
        guard let latestCoordinate = locationPath.last,
              let prevCoordinate = latestCoordinate
        else {
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

extension TrackingMapView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateUserLocationOverlay(location: locations.first)
        if isRunning { drawPath(to: locations.first?.coordinate) }
    }
}

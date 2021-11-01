import UIKit
import MapKit
import CoreLocation

class TrackingViewController: UIViewController {
    private var locationManager = CLLocationManager()
    private var overlay: MKOverlay = MKCircle()

    @IBOutlet weak var trackingMapView: MKMapView!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        locationAuth()

        nextButton.layer.cornerRadius = nextButton.bounds.width/2
        trackingMapView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    private func locationAuth() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

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

extension TrackingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let current = locations.first else {
            return
        }

        let regionRadius: CLLocationDistance = 100
        let overlayRadius: CLLocationDistance = 20
        let coordRegion = MKCoordinateRegion(center: current.coordinate,
                                             latitudinalMeters: regionRadius*2,
                                             longitudinalMeters: regionRadius*2)

        trackingMapView.removeOverlay(overlay)

        overlay = MKCircle(center: current.coordinate, radius: overlayRadius)
        trackingMapView.setRegion(coordRegion, animated: true)

        trackingMapView.addOverlay(overlay)
    }
}

extension TrackingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var circleRenderer = CircleRenderer()
        if let overlay = overlay as? MKCircle {
            circleRenderer = CircleRenderer(circle: overlay)
        }

        return circleRenderer
    }
}

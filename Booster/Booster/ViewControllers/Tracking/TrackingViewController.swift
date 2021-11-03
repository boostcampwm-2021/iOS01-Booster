import UIKit
import MapKit

protocol TrackingProgressDelegate: AnyObject {
    func location(mapView: TrackingMapView)
}

class TrackingViewController: UIViewController {
    private var locationManager = CLLocationManager()
    private var overlay: MKOverlay = MKCircle()
    private var current: CLLocation = CLLocation()

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? TrackingProgressViewController else {
            return
        }
        viewController.delegate = self
    }

    private func locationAuth() {
        let distanceFilter: CLLocationDistance = 5
        locationManager.distanceFilter = distanceFilter
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

extension TrackingViewController: TrackingProgressDelegate {
    func location(mapView: TrackingMapView) {
        mapView.configure(location: current)
    }
}

extension TrackingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let current = locations.first else {
            return
        }
        self.current = current
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

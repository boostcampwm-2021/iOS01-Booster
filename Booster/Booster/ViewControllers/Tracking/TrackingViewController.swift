import UIKit
import MapKit

protocol TrackingProgressDelegate: AnyObject {
    func location(mapView: TrackingMapView)
}

class TrackingViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    enum Segue {
        static let progressSegue = "trackingProgressSegue"
    }

    // MARK: - @IBOutlet
    @IBOutlet private weak var trackingMapView: TrackingMapView!
    @IBOutlet private weak var nextButton: UIButton!

    // MARK: - Properties
    var viewModel: TrackingViewModel = TrackingViewModel()
    private var locationManager = CLLocationManager()
    private var overlay: MKOverlay = MKCircle()
    private var current: CLLocation = CLLocation()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        if let location = self.locationManager.location {
//            self.trackingMapView.setRegion(to: location)
        }
    }

    // MARK: - @IBActions
    @IBAction func startTouchUp(_ sender: UIButton) {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        let countView = TrackingCountDownView(frame: self.view.frame)
        countView.bind {
            self.performSegue(withIdentifier: Segue.progressSegue, sender: nil)
            countView.removeFromSuperview()
        }

        UIView.transition(with: self.view,
                          duration: 0.4,
                          options: [.transitionCurlUp]) {
            self.view.addSubview(countView)
        }
        countView.animate()
    }

    // MARK: - Functions
    func configure() {
        trackingMapView.userTrackingMode = .follow
        nextButton.layer.cornerRadius = nextButton.bounds.width/2
        trackingMapView.delegate = self

        let distanceFilter: CLLocationDistance = 5
        locationManager.distanceFilter = distanceFilter
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            DispatchQueue.main.async { [weak self] in
                self?.locationManager.startUpdatingLocation()
                self?.locationManager.allowsBackgroundLocationUpdates = true
                if let location = self?.locationManager.location {
//                    self?.trackingMapView.setRegion(to: location)
                }
            }
        }
    }
}

// MARK: CLLocation Manager Delegate
extension TrackingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let current = locations.last
        else {
            return
        }
        let overlayRadius: CLLocationDistance = 20

        self.current = current
        trackingMapView.removeOverlay(overlay)

        overlay = MKCircle(center: current.coordinate, radius: overlayRadius)

        trackingMapView.addOverlay(overlay)
    }
}

// MARK: MKMap View Delegate
extension TrackingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var circleRenderer = CircleRenderer()
        if let overlay = overlay as? MKCircle {
            circleRenderer = CircleRenderer(circle: overlay)
        }

        return circleRenderer
    }
}

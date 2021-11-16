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
    @IBOutlet weak var trackingMapView: TrackingMapView!
    @IBOutlet weak var nextButton: UIButton!

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
    }

    // MARK: - @IBActions
    @IBAction func startTouchUp(_ sender: UIButton) {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? TrackingProgressViewController
        else {
            return
        }
        viewController.delegate = self
    }

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
                if let location = self?.locationManager.location {
                    self?.trackingMapView.setRegion(to: location)
                }
            }
        }
    }
}

// MARK: Tracking Progress Delegate
extension TrackingViewController: TrackingProgressDelegate {
    func location(mapView: TrackingMapView) {
        mapView.setRegion(to: current)
    }
}

// MARK: CLLocation Manager Delegate
extension TrackingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let current = locations.first
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

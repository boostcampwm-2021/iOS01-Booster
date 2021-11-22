import UIKit
import MapKit

protocol TrackingProgressDelegate: AnyObject {
    func location(mapView: TrackingMapView)
}

final class TrackingViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    enum Segue {
        static let progressSegue = "trackingProgressSegue"
    }

    // MARK: - @IBOutlet
    @IBOutlet private weak var trackingMapView: TrackingMapView!
    @IBOutlet private weak var nextButton: UIButton!

    // MARK: - Properties
    var viewModel: TrackingViewModel = TrackingViewModel()
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
    func configure() {
        nextButton.layer.cornerRadius = nextButton.bounds.width / 2
        trackingMapView.showsUserLocation = true
        trackingMapView.delegate = self
    }
}

extension TrackingViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
    }
}

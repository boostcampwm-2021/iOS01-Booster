import UIKit
import CoreMotion
import MapKit
import Network
import RxSwift

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
    private let pedometer = CMPedometer()
    private let manager = CLLocationManager()
    private let monitor = NWPathMonitor()
    private let disposeBag = DisposeBag()
    private var overlay: MKOverlay = MKCircle()
    private var current: CLLocation = CLLocation()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        startMonitor()
        manager.requestAlwaysAuthorization()
        pedometer.startUpdates(from: Date()) { _, _ in }
    }
    
    private func startMonitor() {
        monitor.rx
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let element = event.element
                else { return }
                
                switch element.status {
                case .satisfied:
                    self?.nextButton.isUserInteractionEnabled = true
                default :
                    let message = "원활한 서비스를 위해\n네트워크를 연결해주세요"
                    self?.view.showToastView(message: message, isOnTabBar: true)
                    self?.nextButton.isUserInteractionEnabled = false
                }
            }
            .disposed(by: disposeBag)
    }
}

extension TrackingViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
    }
}

import UIKit
import MapKit
import CoreLocation
import CoreMotion

class TrackingProgressMapViewController: UIViewController {
    // MARK: - Enum

    // MARK: - @IBOutlet

    // MARK: - Variables
    private var mapView: MKMapView!
    private let pedometer = CMPedometer()
    private var pedometerLabel: UILabel = {
        let label = UILabel()

        label.text = "1232"
        label.font = .bazaronite(size: 60)
        label.textColor = .black

        return label
    }()
    // MARK: - Subscript

    // MARK: - viewDidLoad or init
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = TrackingMapView(frame: view.frame)
        mapView.delegate = self

        UIConfig()
        layoutConfig()
    }

    override func viewDidAppear(_ animated: Bool) {
//        let countdownView = CountdownView(frame: view.frame)
//        view.addSubview(countdownView)
//        countdownView.start()
        pedometer.startUpdates(from: Date()) { [weak self ] (data, error) in
            if let data = data {
                print("\(data.numberOfSteps)")
                DispatchQueue.main.async {
                    self?.pedometerLabel.text = "\(data.numberOfSteps.intValue)"
                }
            } else {
                print("## error")
            }
        }
    }
    // MARK: - @IBActions

    // MARK: - @objc

    // MARK: - functions
    private func layoutConfig() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        pedometerLabel.translatesAutoresizingMaskIntoConstraints = false

        let mapViewLeading = NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        let mapViewTop = NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        let mapViewTrailing = NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        let mapViewBottom = NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true

        let pedometerLabelTrailing = NSLayoutConstraint(item: pedometerLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        let pedometerLabelBottom = NSLayoutConstraint(item: pedometerLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10).isActive = true
    }

    private func UIConfig() {
        view.addSubview(mapView)
        view.addSubview(pedometerLabel)
    }
}

extension TrackingProgressMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var circleRenderer = CircleRenderer()
        if let overlay = overlay as? MKCircle {
            circleRenderer = CircleRenderer(circle: overlay)
        }
        guard let polyLine = overlay as? MKPolyline else {
            return MKPolylineRenderer()
        }

        let polyLineRenderer = MKPolylineRenderer(polyline: polyLine)

        polyLineRenderer.strokeColor = UIColor(red: 255/255, green: 92/255, blue: 0/255, alpha: 1)
        polyLineRenderer.lineWidth = 8

        return polyLineRenderer
    }
}

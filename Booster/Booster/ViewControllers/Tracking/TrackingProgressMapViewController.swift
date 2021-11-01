import UIKit
import MapKit
import CoreLocation

class TrackingProgressMapViewController: UIViewController {
    // MARK: - Enum

    // MARK: - @IBOutlet

    // MARK: - Variables
    private var mapView: MKMapView!

    // MARK: - Subscript

    // MARK: - viewDidLoad or init
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = TrackingMapView(frame: view.frame)
        view.addSubview(mapView)

        layoutConfig()
        mapView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        let countdownView = CountdownView(frame: view.frame)
        view.addSubview(countdownView)
        countdownView.start()
    }
    // MARK: - @IBActions

    // MARK: - @objc

    // MARK: - functions
    private func layoutConfig() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let leading = NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        let top = NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        let trailing = NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        let bottom = NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
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

//
//  BoosterMapView.swift
//  Booster
//
//  Created by hiju on 2021/11/24.
//

import UIKit
import MapKit

class BoosterMapView: MKMapView {
    enum AnnotationIdentifier: String {
        case milestone
        case startDot
        case endDot
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    func setRegion(to location: CLLocation, meterRadius: Double) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: meterRadius * 2,
                                                  longitudinalMeters: meterRadius * 2)
        setRegion(coordinateRegion, animated: false)
    }

    func addAnnotation(type: AnnotationIdentifier,
                       _ latitude: CLLocationDegrees,
                       _ longitude: CLLocationDegrees) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = type.rawValue

        addAnnotation(annotation)
    }

    func drawPath(from prevCoordinate: CLLocationCoordinate2D?, to currentCoordinate: CLLocationCoordinate2D?) {
        guard let currentCoordinate = currentCoordinate,
              let prevCoordinate = prevCoordinate
        else { return }

        let points: [CLLocationCoordinate2D] = [prevCoordinate, currentCoordinate]
        let line = MKPolyline(coordinates: points, count: points.count)

        addOverlay(line)
    }

    func gradientColorOfCoordinate(indexRatio percentOfPathProgress: Double,
                                   from fromColor: UIColor,
                                   to toColor: UIColor) -> UIColor? {
        let red = fromColor.redValue + ((toColor.redValue - fromColor.redValue) * percentOfPathProgress)
        let green = fromColor.greenValue + ((toColor.greenValue - fromColor.greenValue) * percentOfPathProgress)
        let blue = fromColor.blueValue + ((toColor.blueValue - fromColor.blueValue) * percentOfPathProgress)

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    private func configure() {
        isPitchEnabled = false
    }
}

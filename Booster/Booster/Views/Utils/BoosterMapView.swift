//
//  BoosterMapView.swift
//  Booster
//
//  Created by hiju on 2021/11/24.
//

import UIKit
import MapKit

enum AnnotationIdentifier: String {
    case milestone
    case startDot
    case endDot
}

protocol BoosterMapViewProtocol {
    func setRegion(to location: CLLocation, meterRadius: Double)
    func addAnnotation(type: AnnotationIdentifier, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees)
    func drawPath(from prevCoordinate: CLLocationCoordinate2D?, to currentCoordinate: CLLocationCoordinate2D?)
    func gradientColorOfCoordinate(at coordinate: Coordinate,
                                           coordinates: Coordinates,
                                           from fromColor: UIColor,
                                           to toColor: UIColor) -> UIColor?
}

class BoosterMapView: MKMapView, BoosterMapViewProtocol {
    func setRegion(to location: CLLocation, meterRadius: Double) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                             latitudinalMeters: meterRadius * 2,
                                             longitudinalMeters: meterRadius * 2)
        setRegion(coordinateRegion, animated: false)
    }
    
    func addAnnotation(type: AnnotationIdentifier, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
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
    
    func gradientColorOfCoordinate(at coordinate: Coordinate,
                                           coordinates: Coordinates,
                                           from fromColor: UIColor,
                                           to toColor: UIColor) -> UIColor? {
        guard let indexOfTargetCoordinate = coordinates.firstIndex(of: coordinate)
        else { return nil }

        let percentOfPathProgress = Double(indexOfTargetCoordinate) / Double(coordinates.count)

        let red = fromColor.redValue + ((toColor.redValue - fromColor.redValue) * percentOfPathProgress)
        let green = fromColor.greenValue + ((toColor.greenValue - fromColor.greenValue) * percentOfPathProgress)
        let blue = fromColor.blueValue + ((toColor.blueValue - fromColor.blueValue) * percentOfPathProgress)

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}

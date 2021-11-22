//
//  DetailFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//
import CoreData
import CoreLocation
import MapKit
import UIKit

protocol DetailFeedModelDelegate: AnyObject {
    func detailFeed(viewModel: DetailFeedViewModel)
}

final class DetailFeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    enum AnnotationIdentifier: String {
        case milestone
        case startDot
        case endDot
    }

    // MARK: - Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var locationInfoLabel: UILabel!
    @IBOutlet private weak var stepCountsLabel: UILabel!
    @IBOutlet private weak var kcalLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var kmLabel: UILabel!

    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var mapView: MKMapView!

    weak var delegate: DetailFeedModelDelegate?
    var viewModel = DetailFeedViewModel()

    private var gradientColors: [UIColor] = []

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    // MARK: - @IBActions
    @IBAction private func settingButtonDidTap(_ sender: UIBarButtonItem) {
        let settingAlertController = UIAlertController(title: nil,
                                                       message: nil,
                                                       preferredStyle: .actionSheet)
        let modifyAction = UIAlertAction(title: "글 수정", style: .default) { _ in
            guard let modifyViewController = self.storyboard?.instantiateViewController(withIdentifier: ModifyFeedViewController.identifier) as? ModifyFeedViewController
            else { return }
            modifyViewController.title = "글 수정"
            self.navigationController?.pushViewController(modifyViewController, animated: true)
        }
        let shareAction = UIAlertAction(title: "공유하기", style: .default) { _ in

        }
        let deleteAction = UIAlertAction(title: "글 삭제", style: .destructive) { [weak self] _ in
            let alertController = UIAlertController(title: "글 삭제하기", message: "정말로 산책 기록을 지우시겠어요?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let sureAction = UIAlertAction(title: "기록 지우기", style: .destructive) { _ in
            }
            alertController.addAction(sureAction)
            alertController.addAction(cancelAction)

            self?.present(alertController, animated: true, completion: nil)
        }
        let closeAction = UIAlertAction(title: "닫기", style: .cancel) { _ in

        }
        settingAlertController.addAction(modifyAction)
        settingAlertController.addAction(shareAction)
        settingAlertController.addAction(deleteAction)
        settingAlertController.addAction(closeAction)

        present(settingAlertController,
                animated: true,
                completion: nil)
    }

    // MARK: - Functions
    func configure() {
        delegate?.detailFeed(viewModel: viewModel)
        mapView.layer.cornerRadius = mapView.frame.height / 17
        mapView.delegate = self

        viewModel.trackingModel.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.mapView.removeAnnotations(self?.mapView.annotations ?? [])
                self?.configureUI(value: value)
            }
        }
    }

    private func configureUI(value: TrackingModel) {
        titleLabel.text = value.title
        stepCountsLabel.text = "\(value.steps)"
        kcalLabel.text = "\(value.calories)"
        timeLabel.text = TimeInterval(value.seconds).stringToMinutesAndSeconds()
        kmLabel.text = String(format: "%.2f", value.distance)
        contentTextView.text = value.content

        if value.coordinates.count == 0 { return }

        let points = value.coordinates.map { CLLocationCoordinate2DMake($0.latitude ?? 100.0, $0.longitude ?? 200.0) }.filter { $0.latitude != 100.0 && $0.longitude != 200.0 }

        guard let startPoint = points.first
        else { return }

        findLocationTitle(coordinate: startPoint)
        gradientColors = value.coordinates.map { gradientColorOfCoordinate(at: $0, coordinates: value.coordinates, from: .boosterBackground, to: .boosterOrange) ?? .clear  }

        viewModel.reset()
        createPolyLine(points: points, meter: value.distance)

        for mileStone in value.milestones {
            guard let latitude = mileStone.coordinate.latitude,
                  let longitude = mileStone.coordinate.longitude
            else { continue }

            addAnnotation(type: .milestone,
                          latitude,
                          longitude)
        }
    }

    private func findLocationTitle(coordinate: CLLocationCoordinate2D) {
        let findLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale) { [weak self] placemarks, _ in
            guard let placemarks = placemarks,
                  let address = placemarks.last
            else { return }

            DispatchQueue.main.async {
                self?.locationInfoLabel.text = "\(address.locality ?? "-") \(address.subLocality ?? "-"), \(address.administrativeArea ?? "")"
            }
        }
    }

    private func createPolyLine(points: [CLLocationCoordinate2D], meter: Double) {
        let ((minLatitude, maxLatitude), (minLongitude, maxLongitude)) = points.reduce(((90.0, -90.0), (180.0, -180.0))) { next, current in
            ((min(current.latitude, next.0.0), max(current.latitude, next.0.1)), (min(current.longitude, next.1.0), max(current.longitude, next.1.1)))
        }
        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        let meters = meter + 50

        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude),
                                             latitudinalMeters: meters,
                                             longitudinalMeters: meters), animated: false)

        for (index, point) in points.enumerated() {
            switch index {
            case 0:
                addAnnotation(type: .startDot,
                              point.latitude,
                              point.longitude)
            case 1..<points.count - 2:
                break
            case points.count - 2:
                addAnnotation(type: .endDot,
                              point.latitude,
                              point.longitude)
            default:
                continue
            }
            drawPath(from: point, to: points[index + 1])
        }
    }

    private func drawPath(from prevCoordinate: CLLocationCoordinate2D?, to currentCoordinate: CLLocationCoordinate2D?) {
        guard let currentCoordinate = currentCoordinate,
              let prevCoordinate = prevCoordinate
        else { return }

        let points = [prevCoordinate, currentCoordinate]
        let line = MKPolyline(coordinates: points, count: points.count)

        mapView.addOverlay(line)
    }

    private func addAnnotation(type: AnnotationIdentifier, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = type.rawValue

        mapView.addAnnotation(annotation)
    }

    private func removeMileStoneAnnotation(of mileStone: MileStone) -> Bool {
        guard let annotation = mapView.annotations.first(where: {
            let coordinate = Coordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            return coordinate == mileStone.coordinate
        })
        else { return false }

        mapView.removeAnnotation(annotation)

        return true
    }

    private func gradientColorOfCoordinate(at coordinate: Coordinate,
                                           coordinates: [Coordinate],
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

// MARK: - MapView Delegate
extension DetailFeedViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else { return MKOverlayRenderer() }

        let polyLineRenderer = MKPolylineRenderer(polyline: polyLine)
        polyLineRenderer.strokeColor = gradientColors[viewModel.offsetOfGradientColor()]
        polyLineRenderer.lineWidth = 8
        return polyLineRenderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let coordinate = Coordinate(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

        guard let title = annotation.title,
              let identifier = AnnotationIdentifier(rawValue: title ?? "")
        else { return nil }

        switch identifier {
        case .milestone:
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.milestone.rawValue) {
                annotationView.annotation = annotation
                annotationView.canShowCallout = false
                return annotationView
            } else {
                guard let newAnnotationView = UINib(nibName: PhotoAnnotationView.identifier, bundle: nil).instantiate(withOwner: self, options: nil).first as? PhotoAnnotationView,
                      let mileStone = viewModel.mileStone(at: coordinate)
                else { return nil }

                newAnnotationView.canShowCallout = false
                newAnnotationView.photoImageView.image = UIImage(data: mileStone.imageData)
                newAnnotationView.photoImageView.backgroundColor = .white
                newAnnotationView.changeColor(gradientColors[viewModel.indexOfCoordinate(at: coordinate)])

                newAnnotationView.centerOffset = CGPoint(x: 0, y: -newAnnotationView.frame.height / 2.0)
                return newAnnotationView
            }
        case .startDot, .endDot:
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier.rawValue) {
                annotationView.annotation = annotation
                annotationView.isUserInteractionEnabled = false
                return annotationView
            } else {
                let dotSize = CGSize(width: 18, height: 18)
                let newAnnotationView = MKAnnotationView.init(frame: CGRect(origin: .zero, size: dotSize))
                identifier == .startDot ? (newAnnotationView.backgroundColor = .boosterBackground) : (newAnnotationView.backgroundColor = .boosterOrange)
                newAnnotationView.isUserInteractionEnabled = false
                newAnnotationView.layer.cornerRadius = newAnnotationView.frame.height / 2
                return newAnnotationView
            }
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
         mapView.deselectAnnotation(view.annotation, animated: false)

        let coordinate = Coordinate(latitude: view.annotation?.coordinate.latitude, longitude: view.annotation?.coordinate.longitude)
        guard let selectedMileStone = viewModel.mileStone(at: coordinate)
        else { return }

        let mileStonePhotoViewModel = MileStonePhotoViewModel(mileStone: selectedMileStone)
        let mileStonePhotoViewController = MileStonePhotoViewController(viewModel: mileStonePhotoViewModel)
        mileStonePhotoViewController.viewModel = mileStonePhotoViewModel
        mileStonePhotoViewController.delegate = self

        present(mileStonePhotoViewController, animated: true, completion: nil)
    }
}

// MARK: - MileStone Delete Completed
extension DetailFeedViewController: MileStonePhotoViewControllerDelegate {
    func delete(mileStone: MileStone) {
        if let _ = viewModel.remove(of: mileStone), removeMileStoneAnnotation(of: mileStone) {
            let title = "삭제 완료"
            let message = "마일스톤을 삭제했어요"
            let alertViewController = UIAlertController.simpleAlert(title: title, message: message)
            present(alertViewController, animated: true)
        }
    }
}

//
//  DetailFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//
import CoreData
import MapKit
import UIKit

final class DetailFeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    enum NibName {
        static let photoAnnotationView = "PhotoAnnotationView"
    }

    enum AnnotationIdentifier: String {
        case milestone
        case dot
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

    var viewModel: DetailFeedViewModel

    init?(coder: NSCoder, start date: Date) {
        viewModel = DetailFeedViewModel(start: date)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        let deleteAction = UIAlertAction(title: "글 삭제", style: .destructive) { _ in

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
        mapView.layer.cornerRadius = mapView.frame.height / 17
        mapView.delegate = self

        viewModel.trackingModel.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.configureUI(value: value)
            }
        }

        viewModel.fetchDetailFeedList()
    }

    private func configureUI(value: TrackingModel) {
        if value.coordinates.count == 0 { return }
        let points = value.coordinates.filter { $0.latitude != nil && $0.longitude != nil }
            .map { CLLocationCoordinate2DMake($0.latitude!, $0.longitude!) }

        titleLabel.text = value.title
        stepCountsLabel.text = "\(value.steps)"
        kcalLabel.text = "\(value.calories)"
        timeLabel.text = TimeInterval(value.seconds).stringToMinutesAndSeconds()
        kmLabel.text = String(format: "%.2f", value.distance)
        contentTextView.text = value.content
        createPolyLine(points: points, meter: value.distance)

        for milestone in value.milestones {
            guard let latitude = milestone.coordinate.latitude,
                  let longitude = milestone.coordinate.longitude
            else { continue }

            addAnnotation(type: .milestone,
                          latitude,
                          longitude)
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
            if index > points.count - 2 { break }
            if index == 0 || index == points.count - 2 {
                addAnnotation(type: .dot,
                              point.latitude,
                              point.longitude)
            }
            drawPath(from: point, to: points[index + 1])
        }
    }

    private func drawPath(from prevCoordinate: CLLocationCoordinate2D?, to currentCoordinate: CLLocationCoordinate2D?) {
        guard let currentCoordinate = currentCoordinate,
              let prevCoordinate = prevCoordinate
        else { return }

        let points: [CLLocationCoordinate2D] = [prevCoordinate, currentCoordinate]
        let line = MKPolyline(coordinates: points, count: points.count)

        mapView.addOverlay(line)
    }

    private func addAnnotation(type: AnnotationIdentifier, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = type.rawValue

        mapView.addAnnotation(annotation)
    }

    private func removeMileStoneAnnotation(of mileStone: Milestone) -> Bool {
        guard let annotation = mapView.annotations.first(where: {
            let coordinate = Coordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            return coordinate == mileStone.coordinate
        })
        else { return false }

        mapView.removeAnnotation(annotation)

        return true
    }
}

// MARK: - MapView Delegate
extension DetailFeedViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else { return MKOverlayRenderer() }

        let polyLineRenderer = MKPolylineRenderer(polyline: polyLine)
        polyLineRenderer.strokeColor = .boosterOrange
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
                guard let newAnnotationView = UINib(nibName: NibName.photoAnnotationView, bundle: nil).instantiate(withOwner: self, options: nil).first as? PhotoAnnotationView,
                      let mileStone = viewModel.milestone(at: coordinate)
                else { return nil }

                newAnnotationView.canShowCallout = false
                newAnnotationView.photoImageView.image = UIImage(data: mileStone.imageData)
                newAnnotationView.photoImageView.backgroundColor = .white
                newAnnotationView.centerOffset = CGPoint(x: 0, y: -newAnnotationView.frame.height / 2.0)
                return newAnnotationView
            }
        case .dot:
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationIdentifier.dot.rawValue) {
                annotationView.annotation = annotation
                annotationView.isUserInteractionEnabled = false
                return annotationView
            } else {
                let dotSize = CGSize(width: 18, height: 18)
                let newAnnotationView = MKAnnotationView.init(frame: CGRect(origin: .zero, size: dotSize))
                newAnnotationView.backgroundColor = .boosterOrange
                newAnnotationView.isUserInteractionEnabled = false
                newAnnotationView.layer.cornerRadius = newAnnotationView.frame.height / 2
                return newAnnotationView
            }
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
         mapView.deselectAnnotation(view.annotation, animated: false)
        let coordinate = Coordinate(latitude: view.annotation?.coordinate.latitude, longitude: view.annotation?.coordinate.longitude)
        guard let selectedMileStone = viewModel.milestone(at: coordinate)
        else { return }

        let milestonePhotoViewModel = MilestonePhotoViewModel(milestone: selectedMileStone)
        let milestonePhotoViewController = MilestonePhotoViewController(viewModel: milestonePhotoViewModel)
        milestonePhotoViewController.viewModel = milestonePhotoViewModel
        milestonePhotoViewController.delegate = self

        present(milestonePhotoViewController, animated: true, completion: nil)
    }
}

// MARK: - MileStone Delete Completed
extension DetailFeedViewController: MilestonePhotoViewControllerDelegate {
    func delete(milestone: Milestone) {
        if let _ = viewModel.remove(of: milestone), removeMileStoneAnnotation(of: milestone) {
            let title = "삭제 완료"
            let message = "마일스톤을 삭제했어요"
            let alertViewController = UIAlertController.simpleAlert(title: title, message: message)
            present(alertViewController, animated: true)
        }
    }
}

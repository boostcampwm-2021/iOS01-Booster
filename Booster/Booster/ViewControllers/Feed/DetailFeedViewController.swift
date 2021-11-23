//
//  DetailFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//
import UIKit

import CoreLocation
import MapKit
import RxSwift

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

    var viewModel: DetailFeedViewModel
    private let disposeBag = DisposeBag()

    init?(coder: NSCoder, start date: Date) {
        viewModel = DetailFeedViewModel(start: date)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        let modifyAction = UIAlertAction(title: "글 수정", style: .default) { [weak self] _ in
            self?.presentModifyViewController()
        }
        let shareAction = UIAlertAction(title: "공유하기", style: .default) { _ in

        }
        let deleteAction = UIAlertAction(title: "글 삭제", style: .destructive) { [weak self] _ in
            self?.removeDetailFeed()
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

        bind()
    }

    private func bind() {
        viewModel.trackingModel
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] value in
                guard let model = value.element
                else { return }

                self?.mapView.removeAnnotations(self?.mapView.annotations ?? [])
                self?.configureUI(value: model)

            }
            .disposed(by: disposeBag)

        viewModel.isDeletedAll
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] value in
                guard let isDeleted = value.element
                else { return }

                if isDeleted { self?.presentDeleteAlertController() } else { self?.presentAlertController(title: "삭제 실패", message: "산책 기록을 삭제할 수 없어요\n잠시 후 다시 시도해주세요") }
            }
            .disposed(by: disposeBag)
    }

    private func configureUI(value: TrackingModel) {
        titleLabel.text = value.title
        stepCountsLabel.text = "\(value.steps)"
        kcalLabel.text = "\(value.calories)"
        timeLabel.text = TimeInterval(value.seconds).stringToMinutesAndSeconds()
        kmLabel.text = String(format: "%.2f", value.distance)
        contentTextView.text = value.content

        configureMapView(value: value)
    }

    private func configureMapView(value: TrackingModel) {
        if value.coordinates.count == 0 { return }

        let points = value.coordinates.map { CLLocationCoordinate2DMake($0.latitude ?? 100.0, $0.longitude ?? 200.0) }

        guard let startPoint = points.first
        else { return }

        findLocationTitle(coordinate: startPoint)

        gradientColors = value.coordinates.map { gradientColorOfCoordinate(at: $0, coordinates: value.coordinates, from: .boosterBackground, to: .boosterOrange) ?? .clear  }

        viewModel.reset()
        createPolyLine(points: points, meter: value.distance * 1000)

        for milestone in value.milestones {
            guard let latitude = milestone.coordinate.latitude,
                  let longitude = milestone.coordinate.longitude
            else { continue }

            addAnnotation(type: .milestone,
                          latitude,
                          longitude)
        }
    }

    private func presentModifyViewController() {
        guard let modifyViewController = storyboard?.instantiateViewController(withIdentifier: ModifyFeedViewController.identifier) as? ModifyFeedViewController
        else { return }
        modifyViewController.title = "글 수정"
        navigationController?.pushViewController(modifyViewController, animated: true)
    }

    private func removeDetailFeed() {
        let alertController = UIAlertController(title: "글 삭제하기", message: "정말로 산책 기록을 지우시겠어요?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let sureAction = UIAlertAction(title: "기록 지우기", style: .destructive) { [weak self] _ in
            self?.viewModel.removeAll()
        }
        alertController.addAction(sureAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
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
        let centerLocation = configureCenterLocationOfPath(points: points)
        let meters = meter + 50

        mapView.setRegion(MKCoordinateRegion(center: centerLocation,
                                             latitudinalMeters: meters,
                                             longitudinalMeters: meters), animated: false)
        configureDots(points: points)

        for (index, point) in points.enumerated() {
            if index == points.count - 1 { break }
            drawPath(from: point, to: points[index + 1])
            if points.count == 2 { break }
        }
    }

    private func configureCenterLocationOfPath(points: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let ((minLatitude, maxLatitude), (minLongitude, maxLongitude)) = points.reduce(((90.0, -90.0), (180.0, -180.0))) { next, current in
            ((min(current.latitude, next.0.0), max(current.latitude, next.0.1)), (min(current.longitude, next.1.0), max(current.longitude, next.1.1)))
        }
        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        return CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }

    private func configureDots(points: [CLLocationCoordinate2D]) {
        guard let startPoint = points.first,
              let endPoint = points.last
        else { return }

        addAnnotation(type: .startDot,
                      startPoint.latitude,
                      startPoint.longitude)
        addAnnotation(type: .endDot,
                      endPoint.latitude,
                      endPoint.longitude)
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

    private func removeMileStoneAnnotation(of mileStone: Milestone) -> Bool {
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
                      let mileStone = viewModel.milestone(at: coordinate)
                else { return nil }

                newAnnotationView.canShowCallout = false
                newAnnotationView.photoImageView.image = UIImage(data: mileStone.imageData)
                newAnnotationView.photoImageView.backgroundColor = .white
                newAnnotationView.changeColor(gradientColors[viewModel.indexOfCoordinate(coordinate) ?? 0])

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
        guard let selectedMileStone = viewModel.milestone(at: coordinate)
        else { return }

        let milestonePhotoViewModel = MilestonePhotoViewModel(milestone: selectedMileStone)
        let milestonePhotoViewController = MilestonePhotoViewController(viewModel: milestonePhotoViewModel)
        milestonePhotoViewController.viewModel = milestonePhotoViewModel
        milestonePhotoViewController.delegate = self

        present(milestonePhotoViewController, animated: true, completion: nil)
    }
}

// MARK: - MileStone Delete Method
extension DetailFeedViewController: MilestonePhotoViewControllerDelegate {
    func delete(milestone: Milestone) {
        viewModel.remove(of: milestone)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let isSaved = result.element
                else { return }

                if isSaved {
                    self?.presentAlertController(title: "삭제 완료", message: "마일스톤을 삭제했어요")
                } else {
                    self?.presentAlertController(title: "삭제 오류", message: "마일스톤을 삭제하는 데 문제가 생겼어요\n잠시 후 다시 시도해주세요")
                }
            }
            .disposed(by: disposeBag)
    }

    func presentAlertController(title: String, message: String) {
        let alertController: UIAlertController = .simpleAlert(title: title, message: message)
        present(alertController, animated: true, completion: nil)
    }

    func presentDeleteAlertController() {
        let alertController = UIAlertController(title: "기록 삭제", message: "산책 기록이 삭제되었어요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

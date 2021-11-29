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
    // MARK: - Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var locationInfoLabel: UILabel!
    @IBOutlet private weak var stepCountsLabel: UILabel!
    @IBOutlet private weak var recordView: ThreeColumnRecordView!
    @IBOutlet private weak var settingBarButtonItem: UIBarButtonItem!

    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var pathMapView: DetailFeedMapView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var screenshotView: UIView!

    var viewModel: DetailFeedViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init?(coder: NSCoder, viewModel: DetailFeedViewModel) {
        self.viewModel = viewModel
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configureScrollViewHeight()
    }

    // MARK: - Functions
    func configure() {
        contentTextView.textContainer.lineFragmentPadding = 0
        pathMapView.delegate = self

        bind()
    }

    private func bind() {
        settingBarButtonItem.rx.tap.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.presentSettingAlert()
            })
            .disposed(by: disposeBag)

        viewModel.trackingModel.asDriver()
            .drive(onNext: { [weak self] tracking in
                self?.pathMapView.removeAnnotations(self?.pathMapView.annotations ?? [])
                self?.configureUI(value: tracking)
            })
            .disposed(by: disposeBag)

        viewModel.isDeletedMilestone
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isDeleted in
                if isDeleted { self?.presentAlertController(title: "삭제 완료", message: "마일스톤을 삭제했어요") } else { self?.presentAlertController(title: "삭제 오류", message: "마일스톤을 삭제하는 데 문제가 생겼어요\n잠시 후 다시 시도해주세요") }
            }
            .disposed(by: disposeBag)

        viewModel.isDeletedAll
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isDeleted in
                if isDeleted { self?.presentDeleteAlertController() } else { self?.presentAlertController(title: "삭제 실패", message: "산책 기록을 삭제할 수 없어요\n잠시 후 다시 시도해주세요") }
            }
            .disposed(by: disposeBag)
    }

    private func configureUI(value: TrackingModel) {
        recordView.configureLabels(kcal: "\(value.calories)",
                                   time: TimeInterval(value.seconds).stringToMinutesAndSeconds(),
                                   km: String(format: "%.2f", value.distance))

        titleLabel.text = value.title
        stepCountsLabel.text = "\(value.steps)"
        contentTextView.text = value.content

        configureScrollViewHeight()
        configureMapView(trackingModel: value)
    }

    private func configureScrollViewHeight() {
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentTextView.frame.height + pathMapView.frame.height * 2.5)
    }

    private func configureMapView(trackingModel value: TrackingModel) {
        if value.coordinates.count == 0 { return }
        viewModel.reset()

        pathMapView.configure(trackingModel: value)

        let points: [CLLocationCoordinate2D?] = value.coordinates.all.map {
            if let latitude = $0.latitude,
               let longitude = $0.longitude {
                return CLLocationCoordinate2DMake(latitude, longitude)
            }
            return nil
        }

        guard let start = points.first,
              let startPoint = start
        else { return }

        findLocationTitle(coordinate: startPoint)

        createPath(points: points, meter: value.distance * 1000)
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

    private func createPath(points: [CLLocationCoordinate2D?], meter: Double) {
        configureDots(points: points)

        for (index, point) in points.enumerated() {
            if index == points.count - 1 { break }
            pathMapView.drawPath(from: point, to: points[index + 1])
            if points.count == 2 { break }
        }
    }

    private func configureDots(points: [CLLocationCoordinate2D?]) {
        let compactPoints = points.compactMap { $0 }
        guard let startPoint = compactPoints.first,
              let endPoint = compactPoints.last
        else { return }

        pathMapView.addAnnotation(type: .startDot,
                      startPoint.latitude,
                      startPoint.longitude)
        pathMapView.addAnnotation(type: .endDot,
                      endPoint.latitude,
                      endPoint.longitude)
    }
}

// MARK: - Setting ActionSheet Alert Events
extension DetailFeedViewController {
    private func shareDetailFeedImage() {
        guard let image = screenshotView.snapshot()
        else { return }

        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view

        present(activityViewController, animated: true, completion: nil)
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
}

// MARK: - MapView Delegate
extension DetailFeedViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline,
              let coordinate = viewModel.offsetOfGradientColorCoordinate(),
              let ratio = viewModel.indexRatioOfCoordinate(coordinate)
        else { return MKOverlayRenderer() }

        let polyLineRenderer = MKPolylineRenderer(polyline: polyLine)
        polyLineRenderer.lineWidth = 8
        polyLineRenderer.strokeColor = pathMapView.gradientColorOfCoordinate(indexRatio: ratio,
                                                                             from: .boosterBackground,
                                                                             to: .boosterOrange)
        return polyLineRenderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let coordinate = Coordinate(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

        guard let title = annotation.title,
              let identifier = DetailFeedMapView.AnnotationIdentifier(rawValue: title ?? "")
        else { return nil }

        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier.rawValue) {
            annotationView.annotation = annotation
            annotationView.canShowCallout = false
            return annotationView
        }

        switch identifier {
        case .milestone:
            guard let milestone = viewModel.milestone(at: coordinate),
                  let ratio = viewModel.indexRatioOfCoordinate(coordinate),
                  let annotationView = pathMapView.createMilestoneView(milestone: milestone,
                                                                       color: pathMapView.gradientColorOfCoordinate(indexRatio: ratio,
                                                                                                                    from: .boosterBackground,
                                                                                                                    to: .boosterOrange) ?? .boosterOrange)
            else { return nil }
            return annotationView
        case .startDot, .endDot:
            let annotationView = pathMapView.createDotView()
            identifier == .startDot ? (annotationView.backgroundColor = .boosterBackground) : (annotationView.backgroundColor = .boosterOrange)
            return annotationView
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
         mapView.deselectAnnotation(view.annotation, animated: false)

        presentMilestoneViewController(latitude: view.annotation?.coordinate.latitude, longitude: view.annotation?.coordinate.longitude)
    }
}

// MARK: - Present Controllers
extension DetailFeedViewController {
    private func presentSettingAlert() {
        let settingAlertController = UIAlertController(title: nil,
                                                       message: nil,
                                                       preferredStyle: .actionSheet)
        let modifyAction = UIAlertAction(title: "글 수정", style: .default) { [weak self] _ in
            self?.presentModifyViewController()
        }
        let shareAction = UIAlertAction(title: "공유하기", style: .default) { [weak self] _ in
            self?.shareDetailFeedImage()

        }
        let deleteAction = UIAlertAction(title: "글 삭제", style: .destructive) { [weak self] _ in
            self?.removeDetailFeed()
        }
        let closeAction = UIAlertAction(title: "닫기", style: .cancel)

        settingAlertController.addAction(modifyAction)
        settingAlertController.addAction(shareAction)
        settingAlertController.addAction(deleteAction)
        settingAlertController.addAction(closeAction)

        present(settingAlertController,
                animated: true,
                completion: nil)
    }

    private func presentModifyViewController() {
        let storyboardName = "Feed"
        let modifyViewController = UIStoryboard(name: storyboardName, bundle: .main).instantiateViewController(identifier: ModifyFeedViewController.identifier) { coder in
            return ModifyFeedViewController(coder: coder, viewModel: self.viewModel.createModifyFeedViewModel())
        }
        modifyViewController.delegate = self
        modifyViewController.title = "글 수정"
        navigationController?.pushViewController(modifyViewController, animated: true)
    }

    private func presentMilestoneViewController(latitude: Double?, longitude: Double?) {
        let coordinate = Coordinate(latitude: latitude, longitude: longitude)
        guard let selectedMileStone = viewModel.milestone(at: coordinate)
        else { return }

        let milestonePhotoViewModel = MilestonePhotoViewModel(milestone: selectedMileStone)
        let milestonePhotoViewController = MilestonePhotoViewController(viewModel: milestonePhotoViewModel)
        milestonePhotoViewController.delegate = self

        present(milestonePhotoViewController, animated: true, completion: nil)
    }

    private func presentAlertController(title: String, message: String) {
        let alertController: UIAlertController = .simpleAlert(title: title, message: message)
        present(alertController, animated: true, completion: nil)
    }

    private func presentDeleteAlertController() {
        let alertController = UIAlertController(title: "기록 삭제", message: "산책 기록이 삭제되었어요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - MileStone Delete Method
extension DetailFeedViewController: MilestonePhotoViewControllerDelegate {
    func delete(milestone: Milestone) {
        viewModel.remove(of: milestone)
    }
}

// MARK: - Modify Completed
extension DetailFeedViewController: ModifyFeedViewControllerDelegate {
    func didModifyRecord() {
        viewModel.fetchDetailFeedList()
    }
}

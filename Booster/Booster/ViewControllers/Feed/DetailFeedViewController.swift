//
//  DetailFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//
import CoreData
import MapKit
import UIKit

protocol DetailFeedModelDelegate: AnyObject {
    func detailFeed(viewModel: DetailFeedViewModel)
}

final class DetailFeedViewController: UIViewController, BaseViewControllerTemplate {
    weak var delegate: DetailFeedModelDelegate?

    // MARK: Properties

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var locationInfoLabel: UILabel!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var stepCountsLabel: UILabel!

    // var trackingInfo: TrackingRecord?
    var viewModel = DetailFeedViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    func configure() {
        delegate?.detailFeed(viewModel: viewModel)
        mapView.layer.cornerRadius = mapView.frame.height / 15
        mapView.delegate = self

//        viewModel.trackingModel.bind { [weak self] value in
//            guard let self = self
//            else { return }
//            value.forEach {
//                self.titleLabel.text = $0.title
//                self.locationInfoLabel.text = "\($0.endDate ?? Date())"
//                self.stepCountsLabel.text = "\($0.steps)"
//
//                var points: [CLLocationCoordinate2D] = []
//                let point1 = CLLocationCoordinate2DMake(37.6659862, 126.7710653)
//                let point2 = CLLocationCoordinate2DMake(37.6667059, 126.7714045)
//                let point3 = CLLocationCoordinate2DMake(37.6688112, 126.7705767)
//                points.append(point1)
//                points.append(point2)
//                points.append(point3)
//
//                self.createPolyLine(points: points)
//            }
//        }
    }

    private func createPolyLine(points: [CLLocationCoordinate2D]) {
        mapView.setRegion(MKCoordinateRegion(center: points[0], latitudinalMeters: 300, longitudinalMeters: 300), animated: false)

        let lineDraw = MKPolyline(coordinates: points, count: points.count)
        mapView.addOverlay(lineDraw)
    }

    // 우리나라기준 위도 약 1도: 110km, 1분 1.8km, 1초 30m
    // 경도 약 1도: 88.74km, 1분: 1.479km, 1초: 0.024km = 24m
    private func configureWholeRegion(points: [CLLocationCoordinate2D]) {
    }
}

// MARK: - MapView Delegate
extension DetailFeedViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline
        else { return MKOverlayRenderer() }

        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = .orange
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        return renderer
    }
}

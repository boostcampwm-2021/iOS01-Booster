//
//  DetailFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import UIKit
import MapKit
import CoreData

final class DetailFeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var locationInfoLabel: UILabel!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var stepCountsLabel: UILabel!

    // MARK: - Properties
    var trackingInfo: TrackingRecord?
    var viewModel = DetailFeedViewModel(detailFeedUseCase: DetailFeedUsecase(repository: RepositoryManager()))

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    func configure() {
        mapView.layer.cornerRadius = mapView.frame.height / 15

        viewModel.trackingModel.bind { [weak self] value in
            guard let self = self
            else { return }

            value.forEach {
                self.titleLabel.text = $0.title
                self.locationInfoLabel.text = "\($0.endDate ?? Date())"
                self.stepCountsLabel.text = "\($0.steps)"
                print()
//                print($0.coordinates?.count)
//                print($0.milestones as? MileStone)
            }
        }
    }
}

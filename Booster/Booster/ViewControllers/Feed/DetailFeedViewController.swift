//
//  DetailFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import UIKit
import MapKit

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

    // MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    func configure() {
        delegate?.detailFeed(viewModel: viewModel)
        mapView.layer.cornerRadius = mapView.frame.height / 15
    }
}

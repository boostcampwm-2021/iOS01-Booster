//
//  DetailFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import UIKit
import MapKit

final class DetailFeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var locationInfoLabel: UILabel!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var stepCountsLabel: UILabel!

    // MARK: - Properties
    var trackingInfo: TrackingRecord?
    var viewModel = DetailFeedViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    func configure() {
        mapView.layer.cornerRadius = mapView.frame.height / 15
    }
}

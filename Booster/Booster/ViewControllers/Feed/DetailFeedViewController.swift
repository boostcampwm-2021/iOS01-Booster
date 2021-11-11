//
//  DetailFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import UIKit
import MapKit

final class DetailFeedViewController: UIViewController {

    // MARK: Properties

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var locationInfoLabel: UILabel!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var stepCountsLabel: UILabel!

    // var trackingInfo: TrackingRecord?

    // MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.layer.cornerRadius = mapView.frame.height / 15
    }

}

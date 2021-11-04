//
//  FeedTableViewCell.swift
//  Booster
//
//  Created by hiju on 2021/11/03.
//

import UIKit

final class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var trackingPathView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var totalStepCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with data: TrackingRecord) {
        dateLabel.text = stringToDate(data.date)
        kmLabel.text = "\(data.km)"
        totalStepCountLabel.text = "\(data.totalSteps)"
        titleLabel.text = data.title
        cardBackgroundView.layer.cornerRadius = 25
    }

    private func stringToDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        return dateFormatter.string(from: date)
    }

}

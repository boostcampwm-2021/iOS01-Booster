//
//  FeedCell.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/10.
//

import UIKit

class FeedCell: UICollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var pathImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        let cornerRadius: CGFloat = 13

        layer.cornerRadius = cornerRadius
        dateLabel.font = .bazaronite(size: 12)
        distanceLabel.font = .bazaronite(size: 20)
        weekdayLabel.font = .notoSansKR(.regular, 15)
        stepLabel.font = .bazaronite(size: 45)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        distanceLabel.text = nil
        stepLabel.text = nil
        pathImageView.image = nil
        weekdayLabel.text = nil
    }
}

extension FeedCell: ConfigurableCell {
    func configure(data: (date: Date, distance: Double, step: Int, imageData: Data)) {
        let dateFormatter = DateFormatter()
        let weekdayText = "산책"
        let distanceText = String.init(format: "%.1f", data.distance/1000)
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyyMMDD"

        dateLabel.text = dateFormatter.string(from: data.date)

        dateFormatter.dateFormat = "EEE요일 a "

        distanceLabel.text = "\(distanceText)\nkm"
        weekdayLabel.text = dateFormatter.string(from: data.date)+weekdayText
        stepLabel.text = "\(data.step)"
        pathImageView.image = UIImage(data: data.imageData)

    }
}

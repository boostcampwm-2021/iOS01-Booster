//
//  FeedCell.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/10.
//

import UIKit

class FeedCell: UICollectionViewCell {
    private lazy var emptyView: EmptyView = {
        let view = EmptyView(frame: frame)
        let title = "아직 산책기록이 없어요\n오늘 한 번 천천히 걸어볼까요?"

        view.apply(title: title, image: .assetFoot)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var weekdayLabel: UILabel!
    @IBOutlet private weak var stepLabel: UILabel!
    @IBOutlet private weak var pathImageView: UIImageView!

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
        backgroundColor = .boosterLabel
        emptyView.removeFromSuperview()
        dateLabel.text = nil
        distanceLabel.text = nil
        stepLabel.text = nil
        pathImageView.image = nil
        weekdayLabel.text = nil
    }
}

extension FeedCell: ConfigurableCell {
    func configure(data: (date: Date,
                          distance: Double,
                          step: Int,
                          title: String,
                          imageData: Data,
                          isEmpty: Bool)) {
        if data.isEmpty {
            backgroundColor = .clear
            addSubview(emptyView)
            emptyView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            emptyView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            emptyView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            emptyView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyMMdd"

        dateLabel.text = dateFormatter.string(from: data.date)
        distanceLabel.text = "\(data.distance)\nkm"
        weekdayLabel.text = data.title
        stepLabel.text = "\(data.step)"
        pathImageView.image = UIImage(data: data.imageData)
    }
}

//
//  ThreeColumnRecordView.swift
//  Booster
//
//  Created by hiju on 2021/11/28.
//

import UIKit

final class ThreeColumnRecordView: UIView {
    private var kcalRecordLabel: UILabel = {
        let label = UILabel()
        label.font = .bazaronite(size: 25)
        label.text = "0"
        label.textColor = .boosterLabel
        label.textAlignment = .center
        return label
    }()
    private var timeRecordLabel: UILabel = {
        let label = UILabel()
        label.font = .bazaronite(size: 25)
        label.text = "0h 0m"
        label.textColor = .boosterLabel
        label.textAlignment = .center
        return label
    }()
    private var kmRecordLabel: UILabel = {
        let label = UILabel()
        label.font = .bazaronite(size: 25)
        label.text = "0.0"
        label.textColor = .boosterLabel
        label.textAlignment = .center
        return label
    }()
    private var kcalLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansKR(.light, 15)
        label.text = "kcal"
        label.textColor = .boosterLabel
        label.textAlignment = .center
        return label
    }()
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansKR(.light, 15)
        label.text = "time"
        label.textColor = .boosterLabel
        label.textAlignment = .center
        return label
    }()
    private var kmLabel: UILabel = {
        let label = UILabel()
        label.font = .notoSansKR(.light, 15)
        label.text = "km"
        label.textColor = .boosterLabel
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    func configureLabels(kcal: String, time: String, km: String, timeLabelName: String? = nil) {
        kcalRecordLabel.text = kcal
        timeRecordLabel.text = time
        kmRecordLabel.text = km
        timeLabel.text = timeLabelName ?? "time"
    }

    private func configure() {
        addSubview(kcalRecordLabel)
        addSubview(timeRecordLabel)
        addSubview(kmRecordLabel)
        addSubview(kcalLabel)
        addSubview(timeLabel)
        addSubview(kmLabel)

        kcalRecordLabel.translatesAutoresizingMaskIntoConstraints = false
        kcalRecordLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35).isActive = true
        kcalRecordLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true

        kcalLabel.translatesAutoresizingMaskIntoConstraints = false
        kcalLabel.topAnchor.constraint(equalTo: kcalRecordLabel.bottomAnchor, constant: 5).isActive = true
        kcalLabel.centerXAnchor.constraint(equalToSystemSpacingAfter: kcalRecordLabel.centerXAnchor, multiplier: 0.97).isActive = true

        timeRecordLabel.translatesAutoresizingMaskIntoConstraints = false
        timeRecordLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.008).isActive = true

        timeRecordLabel.centerYAnchor.constraint(equalTo: kcalRecordLabel.centerYAnchor).isActive = true

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: kcalLabel.centerYAnchor).isActive = true

        kmRecordLabel.translatesAutoresizingMaskIntoConstraints = false
        kmRecordLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.65).isActive = true
        kmRecordLabel.centerYAnchor.constraint(equalTo: kcalRecordLabel.centerYAnchor).isActive = true

        kmLabel.translatesAutoresizingMaskIntoConstraints = false
        kmLabel.centerXAnchor.constraint(equalToSystemSpacingAfter: kmRecordLabel.centerXAnchor, multiplier: 0.996).isActive = true
        kmLabel.centerYAnchor.constraint(equalTo: kcalLabel.centerYAnchor).isActive = true
    }
}

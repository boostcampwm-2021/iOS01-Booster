//
//  SelectionChartView.swift
//  Booster
//
//  Created by Hani on 2021/11/28.
//

import UIKit

final class SelectionChartView: UIView {
    private let fontSize: CGFloat = 15

    private lazy var chartView: ChartView = {
        let view = ChartView(frame: CGRect(x: 0,
                                           y: self.fontSize * 2,
                                           width: self.frame.width,
                                           height: self.frame.height - self.fontSize * 2))
        return view
    }()

    private lazy var intervalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bazaronite(size: fontSize)
        label.textColor = UIColor.boosterLabel
        label.frame.origin.y = 0
        return label
    }()

    private lazy var stepCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bazaronite(size: fontSize)
        label.textColor = UIColor.boosterLabel
        label.frame.origin.y = fontSize
        return label
    }()

    private lazy var barView: UIView = {
        let view = UIView()
        view.backgroundColor = .boosterLabel
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addSubviews()
    }

    private func addSubviews() {
        addSubview(chartView)
        addSubview(intervalLabel)
        addSubview(stepCountLabel)
        addSubview(barView)
    }

    func drawChart(stepRatios: [CGFloat], strings: [String]) {
        chartView.drawChart(stepRatios: stepRatios, strings: strings)
    }

    func clearSelection() {
        stepCountLabel.text = String()
        intervalLabel.text = String()
        barView.frame.size = .zero
    }

    func updateSelection(interval: String,
                         step: Int,
                         x: CGFloat,
                         height: CGFloat) {
        intervalLabel.text = interval
        intervalLabel.sizeToFit()
        intervalLabel.center.x = x

        intervalLabel.frame.origin.x = max(intervalLabel.frame.origin.x, 0)
        intervalLabel.frame.origin.x = min(intervalLabel.frame.origin.x, frame.width - intervalLabel.frame.width)

        stepCountLabel.text = "\(step)걸음"
        stepCountLabel.sizeToFit()
        stepCountLabel.center.x = x

        stepCountLabel.frame.origin.x = max(stepCountLabel.frame.origin.x, 0)
        stepCountLabel.frame.origin.x = min(stepCountLabel.frame.origin.x, frame.width - stepCountLabel.frame.width)

        barView.frame = CGRect(x: x,
                               y: chartView.frame.origin.y,
                               width: 1,
                               height: chartView.topSpace + chartView.centerSpace * height)
    }
}

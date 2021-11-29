//
//  ChartView.swift
//  Booster
//
//  Created by Hani on 2021/11/10.
//

import UIKit

final class ChartView: UIView {
    private let graphLayer = CALayer()
    private let textLayer  = CALayer()

    var topSpace: CGFloat { frame.size.height * 0.1 }
    var centerSpace: CGFloat { frame.size.height * 0.8 }
    var bottomSpace: CGFloat { frame.size.height * 0.1 }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSublayers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addSublayers()
    }

    private func addSublayers() {
        graphLayer.frame = CGRect(x: 0,
                                  y: topSpace,
                                  width: frame.size.width,
                                  height: centerSpace)
        layer.addSublayer(graphLayer)

        textLayer.frame = CGRect(x: 0,
                                 y: topSpace + centerSpace,
                                 width: frame.size.width,
                                 height: bottomSpace)
        layer.addSublayer(textLayer)
    }

    func drawChart(stepRatios: [CGFloat], strings: [String]) {
        guard stepRatios.count > 0, strings.count > 0
        else { return }

        self.graphLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let barOffset: CGFloat = graphLayer.frame.width / CGFloat(stepRatios.count)
        let barWidth: CGFloat = barOffset * 0.7
        let barHalfWidth: CGFloat = barWidth / 2

        for (index, stepRatio) in stepRatios.enumerated() {
            let rectangleLayer = CAShapeLayer()
            rectangleLayer.cornerRadius = barHalfWidth
            rectangleLayer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            rectangleLayer.backgroundColor = UIColor.boosterOrange.cgColor
            rectangleLayer.frame = CGRect(x: CGFloat(index) * barOffset + barOffset / 2 - barHalfWidth,
                                          y: (1 - stepRatio) * graphLayer.frame.height,
                                          width: barWidth,
                                          height: graphLayer.frame.height - (1 - stepRatio) * graphLayer.frame.height)
            graphLayer.addSublayer(rectangleLayer)
        }

        textLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let textOffset: CGFloat = textLayer.frame.width / CGFloat(strings.count)

        for (index, string) in strings.enumerated() {
            let dateLayer = CATextLayer()
            dateLayer.string = string
            dateLayer.frame = CGRect(x: CGFloat(index) * textOffset + barOffset / 2 - barHalfWidth,
                                     y: 0,
                                     width: textOffset,
                                     height: textLayer.frame.height)
            dateLayer.fontSize = 14
            dateLayer.foregroundColor = UIColor.boosterLabel.cgColor
            dateLayer.contentsScale = UIScreen.main.scale
            textLayer.addSublayer(dateLayer)
        }
    }
}

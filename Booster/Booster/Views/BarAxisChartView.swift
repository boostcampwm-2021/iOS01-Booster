//
//  BarAxisChartView.swift
//  Booster
//
//  Created by Hani on 2021/11/08.
//

import UIKit

final class BarAxisChartView: UIView {

    // MARK: - Variables

    @IBOutlet weak var barChartView: ChartView!

    private let bottomLayer = CALayer()

    // MARK: - init

    override init(frame: CGRect) {
       super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }

    // MARK: - functions

    override func layoutSubviews() {
        self.bottomLayer.frame = CGRect(x: 0,
                                        y: self.barChartView.frame.height,
                                        width: self.frame.width,
                                        height: self.frame.height - self.barChartView.frame.height)
        self.layer.addSublayer(self.bottomLayer)
    }

    func drawBarAxisChart(cgPoints: [CGPoint], bottomStrings: [String]) {
        self.bottomLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.barChartView.drawBarChart(cgPoints: cgPoints)

        let xOffset: CGFloat = self.bottomLayer.frame.width / CGFloat(cgPoints.count)

        for (cgPoint, bottomString) in zip(cgPoints, bottomStrings) {
            let textLayer = CATextLayer()
            textLayer.string = bottomString
            textLayer.frame = CGRect(x: cgPoint.x * xOffset,
                                     y: bottomLayer.contentsCenter.midY,
                                     width: bottomLayer.frame.width / CGFloat(bottomStrings.count),
                                     height: bottomLayer.frame.height)

            self.bottomLayer.addSublayer(textLayer)
        }
    }

}

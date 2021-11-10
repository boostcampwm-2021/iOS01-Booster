//
//  Chart.swift
//  Booster
//
//  Created by Hani on 2021/11/10.
//

import UIKit

final class Chart: UIView {

    private let graphLayer = CALayer()
    private let textLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        self.graphLayer.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.frame.size.width,
                                       height: self.frame.size.height * 0.8)
        self.layer.addSublayer(self.graphLayer)

        self.textLayer.frame = CGRect(x: 0,
                                      y: self.frame.size.height * 0.8,
                                      width: self.frame.size.width,
                                      height: self.frame.size.height * 0.2)
        self.layer.addSublayer(self.textLayer)
    }

    func drawChart(cgPoints: [CGPoint], strings: [String]) {
        self.graphLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.textLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let xOffset: CGFloat = self.frame.width / CGFloat(cgPoints.count)
        let barWidth: CGFloat = xOffset * 0.7
        let barHalfWidth: CGFloat = barWidth / 2

        for (cgPoint, string) in zip(cgPoints, strings) {
            let rectangleLayer = CAShapeLayer()
            rectangleLayer.frame = CGRect(x: cgPoint.x - barHalfWidth,
                                          y: cgPoint.y,
                                          width: barWidth,
                                          height: self.frame.height - cgPoint.y)

            rectangleLayer.cornerRadius = barHalfWidth
            rectangleLayer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

            rectangleLayer.backgroundColor = .init(red: 255/255, green: 92/255, blue: 0, alpha: 1)
            self.graphLayer.addSublayer(rectangleLayer)

            let dateLayer = CATextLayer()
            dateLayer.string = string
            dateLayer.frame = CGRect(x: cgPoint.x - barHalfWidth,
                                     y: 0,
                                     width: barWidth,
                                     height: self.textLayer.frame.height)

            dateLayer.backgroundColor = .init(red: 255/255, green: 92/255, blue: 0, alpha: 1)
            self.textLayer.addSublayer(dateLayer)
        }
    }

}

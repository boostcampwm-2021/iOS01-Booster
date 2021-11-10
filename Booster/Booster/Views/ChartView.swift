//
//  ChartView.swift
//  Booster
//
//  Created by Hani on 2021/11/08.
//

import UIKit

final class ChartView: UIView {

    // MARK: - init
    
    override init(frame: CGRect) {
       super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }

    // MARK: - functions

    func drawBarChart(cgPoints: [CGPoint]) {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let xOffset: CGFloat = self.frame.width / CGFloat(cgPoints.count)
        let barWidth: CGFloat = xOffset * 0.7
        let barHalfWidth: CGFloat = barWidth / 2

        for cgPoint in cgPoints {
            let rectangleLayer = CAShapeLayer()
            rectangleLayer.frame = CGRect(x: cgPoint.x - barHalfWidth,
                                          y: cgPoint.y,
                                          width: barWidth,
                                          height: self.frame.height - cgPoint.y)

            rectangleLayer.cornerRadius = barHalfWidth
            rectangleLayer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

            rectangleLayer.backgroundColor = .init(red: 255/255, green: 92/255, blue: 0, alpha: 1)
            self.layer.addSublayer(rectangleLayer)
        }
    }

}

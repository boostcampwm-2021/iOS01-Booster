//
//  BarSelectionAxisChartView.swift
//  Booster
//
//  Created by Hani on 2021/11/09.
//

import UIKit

final class BarSelectionAxisChartView: UIView {

    // MARK: - Variables

    @IBOutlet weak var barAxisChartView: BarAxisChartView!

    private let topLayer = CALayer()

    private var isDescriptionViewenabled: Bool = false

    // MARK: - init

    override init(frame: CGRect) {
       super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }

    // MARK: - functions

    override func layoutSubviews() {
        self.topLayer.frame = CGRect(x: 0,
                                     y: 0,
                                     width: self.frame.width,
                                     height: self.frame.height)
        self.layer.addSublayer(self.topLayer)
    }

    func drawChartView(cgPoints: [CGPoint], bottomStrings: [String]) {
        self.barAxisChartView.drawBarAxisChart(cgPoints: cgPoints, bottomStrings: bottomStrings)
    }

    func didTap(at cgPoint: CGPoint) {
        self.topLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        layer.backgroundColor = .init(red: 255/255, green: 92/255, blue: 0, alpha: 1)
        topLayer.addSublayer(layer)
    }

}

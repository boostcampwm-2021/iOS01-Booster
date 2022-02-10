//
//  GradientLabel.swift
//  Booster
//
//  Created by Hani on 2021/11/25.
//

import UIKit

final class GradientLabel: UILabel {
    private enum Opacity {
        static let zero: Float = 0
        static let one: Float = 1
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func drawLabel(step: Int, ratio: Double) {
        text = "\(step)"
        textColor = configureGradientColor(using: ratio)
        
        layer.opacity = Opacity.zero
        UIView.animate(withDuration: 2) { [weak self] in
            self?.layer.opacity = Opacity.one
        }
    }
    
    private func configureGradientColor(using ratio: Double) -> UIColor {
        let correctRatio = ratio > 1 ? 1 : ratio
        let ratio = NSNumber(value: correctRatio * 0.75 + 0.25)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors =  [UIColor.boosterOrange.cgColor, UIColor.boosterLabel.cgColor]
        gradientLayer.locations = [ratio, ratio]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { context in
            gradientLayer.render(in: context.cgContext)
        }
        
        return UIColor(patternImage: image)
    }
}

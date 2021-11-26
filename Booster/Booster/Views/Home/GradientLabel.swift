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

        layer.opacity = Opacity.zero

        let gradientLayer: CAGradientLayer = configuregradientLayer(using: ratio)
        let gradientColor: UIColor = configureGradientColor(using: gradientLayer)
        textColor = gradientColor

        UIView.animate(withDuration: 2) { [weak self] in
            self?.layer.opacity = Opacity.one
        }
    }

    private func configuregradientLayer(using ratio: Double) -> CAGradientLayer {
        let ratio = NSNumber(value: ratio * 0.75 + 0.25)

        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors =  [UIColor.boosterOrange.cgColor, UIColor.boosterLabel.cgColor]
        gradient.locations = [ratio, ratio]
        gradient.startPoint = CGPoint(x: 0.5, y: 1)
        gradient.endPoint = CGPoint(x: 0.5, y: 0)

        return gradient
    }

    private func configureGradientColor(using gradientLayer: CAGradientLayer) -> UIColor {
        UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, 0.0)
        guard let currentContext = UIGraphicsGetCurrentContext()
        else { return .boosterLabel }
        gradientLayer.render(in: currentContext)
        guard let image = UIGraphicsGetImageFromCurrentImageContext()
        else { return .boosterLabel }
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image)
    }
}

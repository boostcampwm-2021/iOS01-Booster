//
//  UIView+Extension.swift
//  Booster
//
//  Created by hiju on 2021/11/28.
//

import UIKit

extension UIView {
    func snapshot() -> UIImage? {
        let currentFrame: CGRect = self.frame

        self.frame = CGRect.init(x: 0,
                                 y: 0,
                                 width: self.frame.size.width,
                                 height: self.frame.size.height)

        UIGraphicsBeginImageContextWithOptions(self.frame.size,
                                               true,
                                               0.0)
        guard let cgContext = UIGraphicsGetCurrentContext()
        else { return nil }
        self.layer.render(in: cgContext)
        guard let image = UIGraphicsGetImageFromCurrentImageContext()
        else { return nil }
        self.frame = currentFrame

        UIGraphicsEndImageContext()

        return image
    }

    func showToastView(message: String, isOnTabBar: Bool = false) {
        let toastView = ToastView.init(frame: CGRect(x: 30,
                                                     y: frame.size.height,
                                                     width: frame.size.width - 60,
                                                     height: 80))
        toastView.configureLabel(message: message)

        self.addSubview(toastView)

        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
        toastView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        toastView.heightAnchor.constraint(equalToConstant: toastView.labelHeight() + 80).isActive = true
        toastView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        let options = KeyframeAnimationOptions(rawValue: AnimationOptions.curveEaseInOut.rawValue)
        UIView.animateKeyframes(withDuration: 3,
                                delay: 0,
                                options: options,
                                animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1 / 3.0) {
                if isOnTabBar {
                    toastView.transform = CGAffineTransform(translationX: 0, y: -(toastView.frame.size.height * 2 + 80))
                }
                else {
                    toastView.transform = CGAffineTransform(translationX: 0, y: -(toastView.frame.size.height * 2 + 30))
                }
            }
            UIView.addKeyframe(withRelativeStartTime: 3.9 / 4.0, relativeDuration: 0.1 / 3.0) {
                toastView.transform = .identity
            }

        }, completion: { _ in
            toastView.removeFromSuperview()
        })
    }
}

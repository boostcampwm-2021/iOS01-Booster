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
}

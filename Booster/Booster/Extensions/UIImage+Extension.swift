//
//  UIImage+Extension.swift
//  Booster
//
//  Created by mong on 2021/11/09.
//

import UIKit

extension UIImage {
    static let boosterArrowLeft = UIImage(systemName: "arrow.left")

    static let systemPause = UIImage(systemName: "pause")
    static let systemCamera = UIImage(systemName: "camera")
    static let systemStop = UIImage(systemName: "stop")
    static let systemPlay = UIImage(systemName: "play")
    static let systemPencil = UIImage(systemName: "pencil")

    enum AssetName: String {
        case foot
    }

    convenience init?(assetName: AssetName) {
        self.init(named: assetName.rawValue)
    }
}

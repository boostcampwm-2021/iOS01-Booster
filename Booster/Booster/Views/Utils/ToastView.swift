//
//  ToastView.swift
//  Booster
//
//  Created by hiju on 2021/11/29.
//

import UIKit

final class ToastView: UIView {
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .boosterOrange
        return imageView
    }()
    private let toastLabel: UILabel = {
        let label = UILabel()
        label.textColor = .boosterLabel
        label.font = .notoSansKR(.medium, 20)
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 5
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureInitialSetting()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureInitialSetting()
    }

    func configureUI(message: String, image: UIImage) {
        toastLabel.text = message
        toastLabel.sizeToFit()
        leftImageView.image = image
    }

    func labelHeight() -> CGFloat {
        return toastLabel.frame.size.height
    }

    private func configureInitialSetting() {
        backgroundColor = .boosterEnableButtonGray
        layer.cornerRadius = frame.size.height / 4

        addSubview(toastLabel)
        addSubview(leftImageView)

        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        leftImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        leftImageView.widthAnchor.constraint(equalToConstant: frame.size.width / 8).isActive = true
        leftImageView.heightAnchor.constraint(equalToConstant: frame.size.width / 8).isActive = true

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        toastLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 15).isActive = true
        toastLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
}

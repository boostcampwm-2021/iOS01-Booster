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
        imageView.image = .caution
        imageView.contentMode = .scaleAspectFit
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

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
    }

    func configureLabel(message: String) {
        toastLabel.text = message
        toastLabel.sizeToFit()
    }

    func labelHeight() -> CGFloat {
        return toastLabel.frame.size.height
    }

    private func configure() {
        backgroundColor = .boosterEnableButtonGray
        layer.cornerRadius = frame.size.height / 4

        addSubview(toastLabel)
        addSubview(leftImageView)

        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        leftImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        leftImageView.widthAnchor.constraint(equalToConstant: frame.size.width / 7).isActive = true
        leftImageView.heightAnchor.constraint(equalToConstant: frame.size.width / 7).isActive = true

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        toastLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 10).isActive = true
        toastLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
}

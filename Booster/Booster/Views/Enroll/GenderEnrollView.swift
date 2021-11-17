//
//  GenderEnrollView.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/16.
//
import UIKit
import RxCocoa

final class GenderEnrollView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: frame)
        let text = "성별이\n어떻게 되나요?"
        label.text = text
        label.textColor = .boosterLabel
        label.font = .notoSansKR(.medium, 35)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var maleButton: UIButton = {
        let button = UIButton(frame: frame)
        let text = "남"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(.makeAttributedString(text: text,
                                                        font: .notoSansKR(.regular, 25),
                                                        color: .boosterBlackLabel), for: .normal)
        button.backgroundColor = .boosterOrange
        button.layer.cornerRadius = 50
        return button
    }()
    lazy var femaleButton: UIButton = {
        let button = UIButton(frame: frame)
        let text = "여"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(.makeAttributedString(text: text,
                                                        font: .notoSansKR(.regular, 25),
                                                        color: .boosterBlackLabel), for: .normal)
        button.backgroundColor = .boosterOrange
        button.layer.cornerRadius = 50
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        UIConfigure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        UIConfigure()
    }

    private func UIConfigure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .boosterBackground
        [titleLabel, maleButton, femaleButton].forEach { self.addSubview($0) }

        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true

        [maleButton, femaleButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 100).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 100).isActive = true
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }

        maleButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: (frame.width-100)/4).isActive = true
        femaleButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -(frame.width-100)/4).isActive = true
    }
}

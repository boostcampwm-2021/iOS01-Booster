//
//  TrackingCountDownView.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/09.
//

import UIKit

class TrackingCountDownView: UIView {
    private var completion: (() -> Void)?
    private lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 25, y: 25, width: 20, height: 20))
        let image = UIImage(systemName: "arrow.left")
        button.tintColor = .white
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(cancelTouchUp(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var defaultLabel: UILabel = {
        let label = UILabel(frame: frame)
        label.font = .bazaronite(size: 150)
        label.textColor = .boosterOrange
        return label
    }()
    private lazy var threeLabel: UILabel = {
        let label = defaultLabel
        let text = "3"
        label.text = text
        label.sizeToFit()
        label.frame.origin = CGPoint(x: frame.maxX, y: frame.maxY/2-label.frame.height/2)
        return label
    }()
    private lazy var twoLabel: UILabel = {
        let label = defaultLabel
        let text = "2"
        label.text = text
        label.sizeToFit()
        label.frame.origin = CGPoint(x: frame.maxX, y: frame.maxY/2-label.frame.height/2)
        return label
    }()
    private lazy var oneLabel: UILabel = {
        let label = defaultLabel
        let text = "1"
        label.text = text
        label.sizeToFit()
        label.frame.origin = CGPoint(x: frame.maxX, y: frame.maxY/2-label.frame.height/2)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .boosterBackground
        addSubview(cancelButton)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .boosterBackground
        addSubview(cancelButton)
    }

    func bind(completion: @escaping () -> Void) {
        self.completion = completion
    }

    func animate() {
        self.addSubview(self.threeLabel)
        UIView.animate(withDuration: 0.15,
                       delay: 0.45,
                       options: .curveEaseOut,
                       animations: {
            self.threeLabel.frame.origin.x = self.frame.maxX/2-self.threeLabel.frame.width/2
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.15,
                           delay: 0.85,
                           options: .curveEaseIn,
                           animations: {
                self.threeLabel.frame.origin.x = -self.threeLabel.frame.width
            },
                           completion: { _ in
                self.threeLabel.removeFromSuperview()
                self.animateTwo()
            })
        })
    }

    private func animateTwo() {
        self.addSubview(self.twoLabel)
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
            self.twoLabel.frame.origin.x = self.frame.maxX/2-self.twoLabel.frame.width/2
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.15,
                           delay: 0.85,
                           options: .curveEaseIn,
                           animations: {
                self.twoLabel.frame.origin.x = -self.twoLabel.frame.width
            },
                           completion: { _ in
                self.twoLabel.removeFromSuperview()
                self.animateOne()
            })
        })
    }

    private func animateOne() {
        self.addSubview(self.oneLabel)
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
            self.oneLabel.frame.origin.x = self.frame.maxX/2-self.oneLabel.frame.width/2
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.15,
                           delay: 0.85,
                           options: .curveEaseIn,
                           animations: {
                self.oneLabel.frame.origin.x = -self.oneLabel.frame.width
            },
                           completion: { _ in
                self.oneLabel.removeFromSuperview()
                self.completion?()
            })
        })
    }

    @objc func cancelTouchUp(_ sender: UIButton) {
        completion = nil
        removeFromSuperview()
    }
}

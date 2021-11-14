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
    private lazy var countLabel: UILabel = {
        let label = UILabel(frame: frame)
        label.font = .bazaronite(size: 150)
        label.textColor = .boosterOrange
        label.frame.origin = CGPoint(x: frame.maxX, y: frame.maxY/2-label.frame.height/2)
        return label
    }()
    private lazy var skipLabel: UILabel = {
        let label = UILabel(frame: frame)
        let text = "스크린 탭하여 카운트 다운 스킵하기"
        label.alpha = 1
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .notoSansKR(.regular, 16)
        label.textColor = .boosterOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
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

    func bind(completion: @escaping () -> Void) {
        self.completion = completion
    }

    @objc func cancelTouchUp(_ sender: UIButton) {
        completion = nil
        removeFromSuperview()
    }

    @objc func trackingViewTapGesture(_ sender: UITapGestureRecognizer) {
        completion?()
        completion = nil
    }

    func animate() {
        var text = "3"
        countLabel.text = text
        countLabel.sizeToFit()
        countLabel.frame.origin = CGPoint(x: frame.maxX, y: frame.maxY/2-countLabel.frame.height/2)
        addSubview(countLabel)
        UIView.animate(withDuration: 0.15,
                       delay: 0.45,
                       options: .curveEaseOut,
                       animations: {
            self.countLabel.frame.origin.x = self.frame.maxX/2-self.countLabel.frame.width/2
        }, completion: { _ in
            UIView.animate(withDuration: 0.15,
                           delay: 0.8,
                           options: .curveEaseIn,
                           animations: {
                self.countLabel.frame.origin.x = 0
                self.countLabel.alpha = 0
            }, completion: { _ in
                self.countLabel.removeFromSuperview()
                text = "2"
                self.countLabel.alpha = 1
                self.countLabel.text = text
                self.countLabel.sizeToFit()
                self.countLabel.frame.origin = CGPoint(x: self.frame.maxX, y: self.frame.maxY/2-self.countLabel.frame.height/2)
                self.addSubview(self.countLabel)
                UIView.animate(withDuration: 0.15,
                               delay: 0,
                               options: .curveEaseOut,
                               animations: {
                    self.countLabel.frame.origin.x = self.frame.maxX/2-self.countLabel.frame.width/2
                }, completion: { _ in
                    UIView.animate(withDuration: 0.15,
                                   delay: 0.8,
                                   options: .curveEaseIn,
                                   animations: {
                        self.countLabel.frame.origin.x = 0
                        self.countLabel.alpha = 0
                    }, completion: { _ in
                        self.countLabel.removeFromSuperview()
                        self.countLabel.alpha = 1
                        text = "1"
                        self.countLabel.text = text
                        self.countLabel.sizeToFit()
                        self.countLabel.frame.origin = CGPoint(x: self.frame.maxX, y: self.frame.maxY/2-self.countLabel.frame.height/2)
                        self.addSubview(self.countLabel)
                        UIView.animate(withDuration: 0.15,
                                       delay: 0,
                                       options: .curveEaseOut,
                                       animations: {
                            self.countLabel.frame.origin.x = self.frame.maxX/2-self.countLabel.frame.width/2
                        }, completion: { _ in
                            UIView.animate(withDuration: 0.15,
                                           delay: 0.8,
                                           options: .curveEaseIn,
                                           animations: {
                                self.countLabel.frame.origin.x = 0
                                self.countLabel.alpha = 0
                            }, completion: { _ in
                                self.countLabel.removeFromSuperview()
                                self.completion?()
                            })
                        })
                    })
                })
            })
        })
    }

    private func configure() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(trackingViewTapGesture(_:)))

        backgroundColor = .boosterBackground
        addSubview(cancelButton)
        addSubview(skipLabel)
        addGestureRecognizer(tapGesture)

        skipLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        skipLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        skipLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -150).isActive = true

    }
}

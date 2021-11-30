//
//  TrackingInfoView.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/27.
//

import UIKit
import RxSwift
import RxCocoa

final class TrackingInfoView: UIView {
    lazy var leftButton: UIButton = {
        let button = UIButton(frame: frame)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.boosterBackground.cgColor
        button.backgroundColor = .boosterOrange
        button.tintColor = .boosterBackground
        button.setImage(.systemCamera, for: .normal)
        button.layer.cornerRadius = 50
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setPreferredSymbolConfiguration(.some(.init(pointSize: 25)), forImageIn: .normal)
        return button
    }()
    lazy var rightButton: UIButton = {
        let button = UIButton(frame: frame)
        button.backgroundColor = .boosterBackground
        button.tintColor = .boosterOrange
        button.setImage(.systemPause, for: .normal)
        button.layer.cornerRadius = 50
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setPreferredSymbolConfiguration(.some(.init(pointSize: 25)), forImageIn: .normal)
        return button
    }()
    lazy var distanceLabel: UILabel = {
        let label = UILabel(frame: frame)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .boosterBlackLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var kcalLabel: UILabel = {
        let label = UILabel(frame: frame)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .boosterBlackLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var timeLabel: UILabel = {
        let label = UILabel(frame: frame)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .boosterBlackLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var pedometerLabel: UILabel = {
        let label = UILabel(frame: frame)
        label.textAlignment = .right
        label.textColor = .boosterBlackLabel
        label.font = .bazaronite(size: 60)
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var titleTextField: UITextField = {
        let textField = UITextField(frame: frame)
        let title = "제목"
        textField.font = .notoSansKR(.medium, 25)
        textField.textColor = .boosterLabel
        textField.attributedPlaceholder = .makeAttributedString(text: title,
                                                                font: .notoSansKR(.medium, 25),
                                                                color: .lightGray)
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.rx.controlEvent([.editingDidEnd])
            .bind { [weak rightButton] in
                rightButton?.isHidden = false
            }
            .disposed(by: disposeBag)
        textField.rx.controlEvent([.editingDidBegin])
            .bind { [weak rightButton] in
                rightButton?.isHidden = true
            }
            .disposed(by: disposeBag)
        textField.delegate = self
        return textField
    }()
    lazy var contentTextView: UITextView = {
        let textView = UITextView()
        let emptyText = "오늘 산책은 어땠나요?"
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.font = .notoSansKR(.light, 17)
        textView.text = emptyText
        textView.textColor = .lightGray
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    private let disposeBag = DisposeBag()
    private weak var pedometerTrailingConstraint: NSLayoutConstraint?
    private weak var pedometerTopConstraint: NSLayoutConstraint?
    private weak var kcalTopConstraint: NSLayoutConstraint?
    private weak var timeTopConstraint: NSLayoutConstraint?
    private weak var distanceTopConstraint: NSLayoutConstraint?
    private weak var rightButtonHeightConstraint: NSLayoutConstraint?
    private weak var rightButtonWidthConstraint: NSLayoutConstraint?
    private weak var rightButtonTrailingConstraint: NSLayoutConstraint?
    private weak var rightButtonBottomConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    func stopPedometerText() {
        let title = " steps"
        let content = "\(pedometerLabel.text ?? "0")"
        leftButton.isHidden = true
        pedometerLabel.attributedText = makeAttributedText(content: content,
                                                           title: title,
                                                           contentFont: .bazaronite(size: 60),
                                                           titleFont: .notoSansKR(.regular, 20),
                                                           color: .boosterOrange)
        pedometerLabel.sizeToFit()
    }

    func stopAnimation() {
        rightButtonWidthConstraint?.constant = 70
        rightButtonHeightConstraint?.constant = 70
        rightButton.layer.cornerRadius = 35
        rightButtonTrailingConstraint?.constant = -25
        rightButtonBottomConstraint?.constant = -25
        pedometerTrailingConstraint?.isActive = false
        pedometerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        pedometerTopConstraint?.constant = 20
        [timeTopConstraint, kcalTopConstraint, distanceTopConstraint].forEach {
            $0?.constant = 130
        }

        rightButton.setImage(.systemPencil, for: .normal)
    }

    func update(state: TrackingProgressViewModel.TrackingState) {
        let isStart: Bool = state == .start
        [distanceLabel, timeLabel, kcalLabel].forEach {
            $0?.textColor = isStart ? .boosterBackground : .boosterLabel
        }

        backgroundColor = isStart ? .boosterOrange : .boosterBackground
        rightButton.backgroundColor = isStart ? .boosterBackground : .boosterOrange
        leftButton.backgroundColor = isStart ? .boosterOrange : .boosterBackground
        leftButton.layer.borderColor = isStart ? UIColor.boosterBackground.cgColor : UIColor.boosterOrange.cgColor
        leftButton.tintColor = isStart ? .boosterBackground : .boosterOrange
        rightButton.tintColor = isStart ? .boosterOrange : .boosterBackground
        rightButton.setImage(isStart ? .systemPause : .systemPlay, for: .normal)
        leftButton.setImage(isStart ? .systemCamera : .systemStop, for: .normal)
    }

    func configure(model: TrackingModel, state: TrackingProgressViewModel.TrackingState) {
        let timeContent = makeTimerText(time: model.seconds)
        let kcalContent = "\(model.calories)\n"
        let distanceContent = "\(String.init(format: "%.1f", model.distance/1000))\n"
        let stepsTitle = "\(state == .end ? " steps" : "")"
        let kcalTitle = "kcal"
        let timeTitle = "time"
        let distanceTitle = "km"
        let stepsColor: UIColor = state == .end ? .boosterOrange : .boosterBlackLabel
        let color: UIColor = state == .start ? .boosterBackground : .boosterLabel

        pedometerLabel.attributedText = makeAttributedText(content: "\(model.steps)",
                                                           title: stepsTitle,
                                                           contentFont: .bazaronite(size: 60),
                                                           titleFont: .notoSansKR(.regular, 20),
                                                           color: stepsColor)
        kcalLabel.attributedText = makeAttributedText(content: kcalContent, title: kcalTitle, color: color)
        timeLabel.attributedText = makeAttributedText(content: timeContent, title: timeTitle, color: color)
        distanceLabel.attributedText = makeAttributedText(content: distanceContent, title: distanceTitle, color: color)
    }

    func configureWrite() {
        addSubview(titleTextField)
        addSubview(contentTextView)
        titleTextField.topAnchor.constraint(equalTo: kcalLabel.bottomAnchor, constant: 40).isActive = true
        titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
        titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10).isActive = true
        contentTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        contentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
        contentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true

        bringSubviewToFront(rightButton)
    }

    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .boosterOrange

        [leftButton, rightButton, distanceLabel, kcalLabel, timeLabel, pedometerLabel]
            .forEach { [weak self] in self?.addSubview($0) }

        leftButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        leftButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true

        rightButtonWidthConstraint = rightButton.widthAnchor.constraint(equalToConstant: 100)
        rightButtonHeightConstraint = rightButton.heightAnchor.constraint(equalToConstant: 100)
        rightButtonTrailingConstraint = rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50)
        rightButtonBottomConstraint = rightButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)

        rightButtonWidthConstraint?.isActive = true
        rightButtonHeightConstraint?.isActive = true
        rightButtonTrailingConstraint?.isActive = true
        rightButtonBottomConstraint?.isActive = true

        distanceTopConstraint = distanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 45)
        distanceLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        distanceTopConstraint?.isActive = true
        let distanceConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: distanceLabel, attribute: .centerX, multiplier: 0.605, constant: 0)
        distanceConstraint.isActive = true

        timeTopConstraint = timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 45)
        timeLabel.widthAnchor.constraint(equalToConstant: 135).isActive = true
        timeTopConstraint?.isActive = true
        let timeConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: timeLabel, attribute: .centerX, multiplier: 1.008, constant: 0)
        timeConstraint.isActive = true

        kcalTopConstraint = kcalLabel.topAnchor.constraint(equalTo: topAnchor, constant: 45)
        kcalLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        kcalTopConstraint?.isActive = true
        let kcalConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: kcalLabel, attribute: .centerX, multiplier: 2.83, constant: 0)
        kcalConstraint.isActive = true

        pedometerTopConstraint = pedometerLabel.topAnchor.constraint(equalTo: topAnchor, constant: -80)
        pedometerTrailingConstraint = pedometerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        pedometerTopConstraint?.isActive = true
        pedometerTrailingConstraint?.isActive = true
    }

    private func makeTimerText(time: Int) -> String {
        let seconds = time % 60
        let minutes = time / 60
        var text = ""
        text += "\(minutes < 10 ? "0\(minutes)'" : "\(minutes)'")"
        text += "\(seconds < 10 ? "0\(seconds)\"\n" : "\(seconds)\"\n")"
        return text
    }

    private func makeAttributedText(content: String,
                                    title: String,
                                    contentFont: UIFont = .bazaronite(size: 30),
                                    titleFont: UIFont = .notoSansKR(.light, 15),
                                    color: UIColor = .black)
    -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString()

        let contentText: NSAttributedString = .makeAttributedString(text: content,
                                                                    font: contentFont,
                                                                    color: color)
        let titleText: NSAttributedString = .makeAttributedString(text: title,
                                                                  font: titleFont,
                                                                  color: color)

        [contentText, titleText].forEach {
            mutableString.append($0)
        }

        return mutableString
    }
}

// MARK: text field delegate
extension TrackingInfoView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text
        else { return true }

        let maximum = 15

        return text.count + string.count < maximum
    }
}

// MARK: text view delegate
extension TrackingInfoView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .boosterLabel
        }

        rightButton.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            let emptyText = "오늘 산책은 어땠나요?"
            textView.text = emptyText
            textView.textColor = .lightGray
        }
        rightButton.isHidden = false
    }
}

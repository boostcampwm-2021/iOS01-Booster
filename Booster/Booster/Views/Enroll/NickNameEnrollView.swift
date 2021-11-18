//
//  NickNameEnrollView.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/17.
//

import UIKit

final class NickNameEnrollView: UIView {
    private var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    lazy var nickNameTextField: UITextField = {
        let textField = UITextField(frame: frame)
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.autocapitalizationType = .none
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.spellCheckingType = .no
        textField.attributedPlaceholder = .makeAttributedString(text: "입력",
                                                                font: .notoSansKR(.regular, 35),
                                                                color: .boosterGray)
        textField.tintColor = .boosterOrange
        textField.font = .notoSansKR(.regular, 35)
        textField.textColor = .boosterLabel
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    lazy var startButton: UIButton = {
        let button = UIButton(frame: frame)
        button.backgroundColor = .boosterOrange
        button.setAttributedTitle(.makeAttributedString(text: "시작",
                                                        font: .notoSansKR(.bold, 18),
                                                        color: .boosterBlackLabel), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 50
        return button
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: frame)
        let text = "자신의 별명을\n지어주세요"
        label.text = text
        label.textColor = .boosterLabel
        label.font = .notoSansKR(.medium, 35)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        UIConfigure()
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        UIConfigure()
        configure()
    }

    private func configure() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self.bottomConstraint.constant = -keyboardHeight - 30
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { _ in
            self.bottomConstraint.constant = -30
        }
    }

    private func UIConfigure() {
        backgroundColor = .boosterBackground
        [nickNameTextField, startButton, titleLabel].forEach { self.addSubview($0) }

        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true

        nickNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        nickNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
        nickNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50).isActive = true

        startButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        startButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        bottomConstraint = startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
        bottomConstraint.isActive = true

        nickNameTextField.becomeFirstResponder()
    }
}

extension NickNameEnrollView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text
        else { return true }
        
        let maximum = 9
        
        return text.count + string.count < maximum
    }
}

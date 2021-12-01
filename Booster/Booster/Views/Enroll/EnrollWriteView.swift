//
//  EnrollWriteView.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/16.
//

import UIKit
import RxCocoa

final class EnrollWriteView: UIView {
    private var type: PickerInfoType
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: frame)
        label.textColor = .boosterLabel
        label.font = .notoSansKR(.medium, 35)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var unitLabel: UILabel = {
        let label = UILabel(frame: frame)
        label.textColor = .boosterLabel
        label.font = .notoSansKR(.regular, 35)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var displayTextField: EnrollTextField = {
        let textField = EnrollTextField(frame: frame)
        textField.delegate = self
        textField.textColor = .boosterLabel
        textField.font = .notoSansKR(.regular, 35)
        textField.textAlignment = .left
        textField.sizeToFit()
        textField.tintColor = .boosterOrange
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    lazy var nextButton: UIButton = {
        let button = UIButton(frame: frame)
        button.backgroundColor = .boosterOrange
        button.setImage(.systemChevronRight, for: .normal)
        button.tintColor = .boosterBlackLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 33
        return button
    }()
    lazy var pickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: frame, type: self.type)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    private lazy var bottomConstraint: NSLayoutConstraint = {
        return nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)
    }()
    var lowerBound: Int = 0

    override init(frame: CGRect) {
        type = .age
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        type = .age
        super.init(coder: coder)
        configureUI()
    }

    convenience init(frame: CGRect, title: String, type: PickerInfoType) {
        self.init(frame: frame)
        titleLabel.text = title
        displayTextField.text = "\(type.range.lowerBound + type.startRow)"
        self.type = type
        unitLabel.text = type.unit
        displayTextField.inputView = pickerView
        lowerBound = type.range.lowerBound
        bind()
        displayTextField.becomeFirstResponder()
    }

    private func bind() {
        _ = pickerView.rx.itemSelected
            .map { row, _ in
                return "\(self.type.range.lowerBound + row)"
            }.bind { [weak self] value in
                self?.displayTextField.text = value
            }
    }

    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .boosterBackground
        [titleLabel, nextButton, displayTextField, unitLabel].forEach { self.addSubview($0) }

        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true

        displayTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50).isActive = true
        displayTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true

        unitLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50).isActive = true
        unitLabel.leadingAnchor.constraint(equalTo: displayTextField.trailingAnchor, constant: 10).isActive = true

        nextButton.widthAnchor.constraint(equalToConstant: 66).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 66).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        bottomConstraint.isActive = true
    }
}

extension EnrollWriteView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        bottomConstraint.constant = -250
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        bottomConstraint.constant = -30
    }
}

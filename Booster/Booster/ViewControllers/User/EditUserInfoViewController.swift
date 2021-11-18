//
//  EditUserInfoViewController.swift
//  Booster
//
//  Created by mong on 2021/11/18.
//

import UIKit

class EditUserInfoViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    private enum genderButtonType: String {
        case male = "남"
        case female = "여"

        mutating func toggle() {
            if self == .male { self = .female } else { self = .male }
        }
    }

    // MARK: - @IBOutlet
    @IBOutlet var nickNameTextField: EditUserInfoTextField!
    @IBOutlet var heightTextField: EditUserInfoTextField!
    @IBOutlet var weightTextField: EditUserInfoTextField!
    @IBOutlet var ageTextField: EditUserInfoTextField!
    @IBOutlet var maleGenderButton: UIButton!
    @IBOutlet var femaleGenderButton: UIButton!

    // MARK: - Properties
    var viewModel: UserViewModel

    private var genderButtonState: genderButtonType = .female

    // MARK: - Init
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    init?(coder: NSCoder, viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        UIButtonConfigure()
        UITextFieldConfigure()
    }

    // MARK: - @IBActions
    @IBAction func backButtonDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func editDoneButtonDidTap(_ sender: Any) {
        if let nickName = nickNameTextField.text,
           let heightText = heightTextField.text,
           let height = Int(heightText),
           let weightText = weightTextField.text,
           let weight = Int(weightText),
           let ageText = ageTextField.text,
           let age = Int(ageText) {
            saveEditedUserInfo(gender: genderButtonState.rawValue,
                               age: age,
                               height: height,
                               weight: weight,
                               nickName: nickName)
        }
    }

    @IBAction func genderButtonDidTap(_ sender: Any) {
        genderButtonState.toggle()
        maleGenderButton.isEnabled.toggle()
        femaleGenderButton.isEnabled.toggle()
    }

    // MARK: - Functions
    private func saveEditedUserInfo(gender: String,
                                    age: Int,
                                    height: Int,
                                    weight: Int,
                                    nickName: String) {
        viewModel.editUserInfo(gender: gender,
                               age: age,
                               height: height,
                               weight: weight,
                               nickname: nickName)
        viewModel.save { [weak self] (isSaved) in
            DispatchQueue.main.async {
                var alert = UIAlertController()
                if isSaved {
                    alert = UIAlertController.simpleAlert(title: "", message: "수정 완료")
                } else {
                    alert = UIAlertController.simpleAlert(title: "", message: "수정 실패")
                }
                self?.present(alert, animated: true) {
                    self?.navigationController?.popViewController(animated: true)
                    dump(self?.viewModel)
                }
            }
        }
    }

    private func UIButtonConfigure() {
        femaleGenderButton.isEnabled = false
        maleGenderButton.isEnabled = true

        maleGenderButton.setBackgroundColor(color: .boosterOrange, for: .disabled)
        maleGenderButton.setBackgroundColor(color: .boosterEnableButtonGray, for: .normal)
        femaleGenderButton.setBackgroundColor(color: .boosterOrange, for: .disabled)
        femaleGenderButton.setBackgroundColor(color: .boosterEnableButtonGray, for: .normal)
    }

    private func UITextFieldConfigure() {
        let frame = CGRect(x: 0, y: view.frame.height - 200, width: view.frame.width, height: 200)
        heightTextField.inputView = InfoPickerView(frame: frame, type: .height)
        weightTextField.inputView = InfoPickerView(frame: frame, type: .weight)
        ageTextField.inputView = InfoPickerView(frame: frame, type: .age)
    }
}

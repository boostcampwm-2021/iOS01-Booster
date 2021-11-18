//
//  EditUserInfoViewController.swift
//  Booster
//
//  Created by mong on 2021/11/18.
//

import UIKit
import RxCocoa
import RxSwift

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

    private lazy var pickerViewFrame = CGRect(x: 0, y: view.frame.height - 170, width: view.frame.width, height: 170)
    private var disposalBag: DisposeBag = DisposeBag()
    private lazy var heightPickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: pickerViewFrame, type: .height)
        pickerView.rx.itemSelected.map { (row, _) -> Int in
            return Int(row + pickerView.type.range.lowerBound)
        }.bind { [weak self] (value) in
            self?.heightTextField.text = "\(value)"
        }.disposed(by: disposalBag)

        return pickerView
    }()

    private lazy var weightPickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: pickerViewFrame, type: .weight)
        pickerView.rx.itemSelected.map { (row, _) -> Int in
            return Int(row + pickerView.type.range.lowerBound)
        }.bind { [weak self] (value) in
            self?.weightTextField.text = "\(value)"
        }.disposed(by: disposalBag)

        return pickerView
    }()

    private lazy var agePickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: pickerViewFrame, type: .age)
        pickerView.rx.itemSelected.map { (row, _) -> Int in
            return Int(row + pickerView.type.range.lowerBound)
        }.bind { [weak self] (value) in
            self?.ageTextField.text = "\(value)"
        }.disposed(by: disposalBag)

        return pickerView
    }()

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
        let nickNameText = nickNameTextField.text ?? ""
        let heightText = heightTextField.text ?? ""
        let weightText = weightTextField.text ?? ""
        let ageText = ageTextField.text ?? ""
        saveEditedUserInfo(gender: genderButtonState.rawValue,
                           age: ageText,
                           height: heightText,
                           weight: weightText,
                           nickName: nickNameText)
    }

    @IBAction func genderButtonDidTap(_ sender: Any) {
        genderButtonState.toggle()
        maleGenderButton.isEnabled.toggle()
        femaleGenderButton.isEnabled.toggle()
        AllTextFieldResignFirstResponder()
    }

    @IBAction func viewDidTap(_ sender: Any) {
        AllTextFieldResignFirstResponder()
    }

    // MARK: - Functions
    private func saveEditedUserInfo(gender: String,
                                    age: String,
                                    height: String,
                                    weight: String,
                                    nickName: String) {
        let gender = gender
        let age = Int(age) ?? nil
        let height = Int(height) ?? nil
        let weight = Int(weight) ?? nil
        let nickName = nickName == "" ? nil : nickName
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
        heightTextField.inputView = heightPickerView
        weightTextField.inputView = weightPickerView
        ageTextField.inputView = agePickerView
    }

    private func AllTextFieldResignFirstResponder() {
        nickNameTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
    }
}

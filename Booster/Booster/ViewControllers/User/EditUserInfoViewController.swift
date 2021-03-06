//
//  EditUserInfoViewController.swift
//  Booster
//
//  Created by mong on 2021/11/18.
//

import UIKit
import RxCocoa
import RxSwift

final class EditUserInfoViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    private enum GenderButtonType: String {
        case male = "남"
        case female = "여"

        mutating func toggle() {
            (self == .male) ? (self = .female) : (self = .male)
        }
    }

    // MARK: - @IBOutlet
    @IBOutlet private weak var nickNameTextField: EditUserInfoTextField!
    @IBOutlet private weak var heightTextField: EditUserInfoTextField!
    @IBOutlet private weak var weightTextField: EditUserInfoTextField!
    @IBOutlet private weak var ageTextField: EditUserInfoTextField!
    @IBOutlet private weak var maleGenderButton: UIButton!
    @IBOutlet private weak var femaleGenderButton: UIButton!

    // MARK: - Properties
    var viewModel: UserViewModel

    private let disposeBag = DisposeBag()
    private var genderButtonState: GenderButtonType = .female
    private lazy var pickerViewFrame = CGRect(x: 0,
                                              y: view.frame.height - 170,
                                              width: view.frame.width,
                                              height: 170)
    private lazy var heightPickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: pickerViewFrame, type: .height)
        pickerView.rx.itemSelected.map { (row, _) -> Int in
            return Int(row + pickerView.type.range.lowerBound)
        }.bind { [weak self] value in
            self?.heightTextField.text = "\(value)"
        }.disposed(by: disposeBag)

        return pickerView
    }()

    private lazy var weightPickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: pickerViewFrame, type: .weight)
        pickerView.rx.itemSelected.map { (row, _) -> Int in
            return Int(row + pickerView.type.range.lowerBound)
        }.bind { [weak self] value in
            self?.weightTextField.text = "\(value)"
        }.disposed(by: disposeBag)

        return pickerView
    }()

    private lazy var agePickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: pickerViewFrame, type: .age)
        pickerView.rx.itemSelected.map { (row, _) -> Int in
            return Int(row + pickerView.type.range.lowerBound)
        }.bind { [weak self] value in
            self?.ageTextField.text = "\(value)"
        }.disposed(by: disposeBag)

        return pickerView
    }()

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

        configureNavigationBarTitle()
        configureUIButton()
        configureUITextField()
        bind()
    }

    // MARK: - @IBActions
    @IBAction private func backButtonDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func editDoneButtonDidTap(_ sender: Any) {
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

    @IBAction private func genderButtonDidTap(_ sender: Any) {
        genderButtonState.toggle()
        maleGenderButton.isEnabled.toggle()
        femaleGenderButton.isEnabled.toggle()
        allTextFieldResignFirstResponder()
    }

    @IBAction private func viewDidTap(_ sender: Any) {
        allTextFieldResignFirstResponder()
    }

    // MARK: - Functions
    private func bind() {
        viewModel.model.asDriver()
            .drive(onNext: { [weak self] userInfo in
                guard let self = self,
                      let genderType = GenderButtonType(rawValue: userInfo.gender)
                else { return }

                self.genderButtonState = genderType
                self.setButtonState(by: genderType)
                self.nickNameTextField.text = userInfo.nickname
                self.heightTextField.text = "\(userInfo.height)"
                self.weightTextField.text = "\(userInfo.weight)"
                self.ageTextField.text = "\(userInfo.age)"
            }).disposed(by: disposeBag)
        
        viewModel.isEditingComplete
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] success in
                guard let self = self
                else { return }
                
                if success {
                    let title = "수정 완료"
                    let message = "수정을 완료했어요"
                    self.presentPopViewControllerAlertController(title: title, message: message)
                } else {
                    let title = "수정 실패"
                    let message = "알 수 없는 이유로 수정에 실패했어요\n다시 시도해 주세요"
                    self.presentPopViewControllerAlertController(title: title, message: message)
                }
            }).disposed(by: disposeBag)
    }

    private func configureNavigationBarTitle() {
        navigationItem.title = "개인 정보 수정"
    }

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
    }

    private func configureUIButton() {
        maleGenderButton.isEnabled = true
        femaleGenderButton.isEnabled = true

        maleGenderButton.setBackgroundColor(color: .boosterOrange, for: .disabled)
        maleGenderButton.setBackgroundColor(color: .boosterEnableButtonGray, for: .normal)
        femaleGenderButton.setBackgroundColor(color: .boosterOrange, for: .disabled)
        femaleGenderButton.setBackgroundColor(color: .boosterEnableButtonGray, for: .normal)
    }

    private func configureUITextField() {
        heightTextField.inputView = heightPickerView
        weightTextField.inputView = weightPickerView
        ageTextField.inputView = agePickerView
    }

    private func allTextFieldResignFirstResponder() {
        nickNameTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
    }

    private func setButtonState(by gender: GenderButtonType) {
        (gender == .male) ? (maleGenderButton.isEnabled = false) : (femaleGenderButton.isEnabled = false)
    }

    private func presentPopViewControllerAlertController(title: String, message: String) {
        let alert = UIAlertController.simpleAlert(title: title,
                                              message: message,
                                              action: { [weak self] _ -> Void in
            self?.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true, completion: nil)
    }
}

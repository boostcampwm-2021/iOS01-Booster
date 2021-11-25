//
//  ChangeGoalViewController.swift
//  Booster
//
//  Created by mong on 2021/11/17.
//

import UIKit
import RxSwift
import RxCocoa

class ChangeGoalViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stepsTextField: UITextField!

    // MARK: - Properties
    var viewModel: UserViewModel
    private let usecase = UserUsecase()
    private let disposeBag = DisposeBag()

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

        stepsTextField.delegate = self

        configureNavigationBarTitle()
        configureUI()
        bind()
    }

    // MARK: - @IBActions
    @IBAction private func backButtonDidTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func saveButtonDidTap(_ sender: UIButton) {
        guard let goalText = stepsTextField.text,
              let goal = Int(goalText)
        else { return }

        changeGoal(to: goal)
    }

    // MARK: - Functions
    private func bind() {
        viewModel.model.asDriver()
            .drive(onNext: { [weak self] result in
                self?.setTitleLabelText(to: result.goal)
                self?.setPlaceholderOfGoalTextField(steps: result.goal)
            }).disposed(by: disposeBag)
    }

    private func configureNavigationBarTitle() {
        navigationItem.title = "목표 바꾸기"
    }

    private func configureUI() {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: stepsTextField.frame.size.height - 1, width: stepsTextField.frame.size.width, height: 1)
        border.backgroundColor = UIColor.boosterOrange.cgColor
        stepsTextField.layer.addSublayer(border)
        stepsTextField.layer.masksToBounds = true
    }

    private func setPlaceholderOfGoalTextField(steps: Int) {
        stepsTextField.clearsOnBeginEditing = true
        stepsTextField.textColor = .boosterGray
        stepsTextField.text = attributedTextOfcurrentGoal(steps: steps)
    }

    private func setTitleLabelText(to goal: Int) {
        let title = "현재 목표는\n\(goal) 걸음이에요\n얼마나 바꿔볼까요?"
        titleLabel.text = title
    }

    private func attributedTextOfcurrentGoal(steps: Int) -> String {
        let attributedString = NSAttributedString(string: "\(steps)", attributes: [.foregroundColor: UIColor.boosterGray])

        return attributedString.string
    }

    private func changeGoalValidator() -> Bool {
        guard let stepsText = stepsTextField.text,
              let steps = Int(stepsText)
        else { return false }

        if steps == 0 { return false }

        return true
    }

    private func changeGoal(to goal: Int) {
        if changeGoalValidator() {
            updateGoal(goal: goal)
        } else {
            let title = "변경 실패"
            let message = "걸음 수가 빈칸 이거나 0인지 확인해주세요"
            let alert = UIAlertController.simpleAlert(title: title, message: message)
            present(alert, animated: true, completion: nil)
        }
    }

    private func updateGoal(goal: Int) {
        viewModel.changeGoal(to: goal)
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self = self
                else { return }

                var alert = UIAlertController()

                if result {
                    NotificationCenter.default.post(name: .init(rawValue: "DidUpdateGoal"), object: goal)
                    let title = "변경 성공"
                    let message = "걸음 수를 \(goal)으로 변경했어요"
                    alert = self.popViewControllerAlertController(title: title, message: message)
                } else {
                    let title = "변경 실패"
                    let message = "알 수 없는 오류로 변경을 할 수 없어요"
                    alert = UIAlertController.simpleAlert(title: title, message: message)
                }
                self.present(alert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }

    private func popViewControllerAlertController(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController.simpleAlert(title: title,
                                              message: message,
                                              action: { (_) -> Void in
            self.navigationController?.popViewController(animated: true)
        })

        return alert
    }
}

// MARK: - UITextFieldDelegate
extension ChangeGoalViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        stepsTextField.textColor = .boosterOrange

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text
        else { return true }

        let maxLength = 5
        let length = text.count + string.count - range.length

        return length <= maxLength
    }
}

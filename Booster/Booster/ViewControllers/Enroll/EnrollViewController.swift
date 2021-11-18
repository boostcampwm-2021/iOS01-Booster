//
//  EnrollViewController.swift
//  Booster
//
//  Created by mong on 2021/11/04.
//

import UIKit
import RxCocoa
import RxSwift

final class EnrollViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: Enum
    private enum InfoStep: Int {
        case gender = 1, age, height, weight, nickName

        static func changeStep(number: Int) -> InfoStep? {
                return self.init(rawValue: number)
            }
    }

    // MARK: Properties
    private let disposeBag: DisposeBag = DisposeBag()
    private var infoStep: InfoStep = .gender
    private lazy var backButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem()
        buttonItem.image = .systemArrowLeft
        buttonItem.tintColor = .boosterLabel
        buttonItem.rx.tap
            .bind { [weak self] in
                guard let self = self
                else { return }
                let minimum = 1

                self.view.subviews.last?.removeFromSuperview()
                self.navigationItem.leftBarButtonItem = self.view.subviews.count > minimum ? self.backButtonItem : nil
                self.infoStep = InfoStep.changeStep(number: self.view.subviews.count) ?? .gender
                self.navigationItem.rightBarButtonItem = self.skipButtonItem
            }.disposed(by: disposeBag)
        return buttonItem
    }()
    private lazy var skipButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem()
        let title = "건너뛰기"
        buttonItem.title = "건너뛰기"
        buttonItem.tintColor = .boosterGray
        buttonItem.rx.tap
            .bind { [weak self] in
                guard let self = self
                else { return }
                self.view.endEditing(true)
                self.viewModel.step.onNext(self.infoStep.rawValue+1)
            }.disposed(by: disposeBag)
        return buttonItem
    }()
    private lazy var genderEnrollView: GenderEnrollView = {
        let view = GenderEnrollView(frame: view.frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.maleButton.rx.tap
            .bind { [weak self] _ in
                self?.viewModel.gender.onNext(false)
            }
            .disposed(by: disposeBag)
        view.femaleButton.rx.tap
            .bind { [weak self] _ in
                self?.viewModel.gender.onNext(true)
            }
            .disposed(by: disposeBag)
        return view
    }()
    private lazy var nickNameView: NicknameEnrollView = {
        let view = NicknameEnrollView(frame: view.frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.nicknameTextField.rx.text
            .bind { [weak self] value in
                guard let self = self,
                      let value = value
                else { return }

                self.viewModel.nickName.onNext(value)
            }.disposed(by: disposeBag)
        view.startButton.rx.tap
            .bind { [weak self] in
                guard let self = self,
                      let empty = view.nicknameTextField.text?.isEmpty
                else { return }
                let nextStep: Int = 6

                if empty {
                    let title = "별명"
                    let message = "별명을 입력해주시기 바랍니다."
                    let alertController: UIAlertController = .simpleAlert(title: title, message: message)
                    self.present(alertController, animated: true)
                    return
                }

                self.viewModel.step.onNext(nextStep)
            }.disposed(by: disposeBag)
        return view
    }()
    var viewModel: EnrollViewModel = EnrollViewModel()

    // MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModelStepBind()
        viewModelSavebind()
        configureUI()
    }

    // MARK: Methods
    private func display(enrollView: UIView) {
        let navigationBar = navigationController?.navigationBar
        let transition = CATransition()
        let minimum = 1
        transition.type = .push
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        transition.duration = 0.3

        view.layer.add(transition, forKey: nil)
        view.addSubview(enrollView)

        navigationItem.leftBarButtonItem = view.subviews.count > minimum ? backButtonItem : nil

        enrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20 + (navigationBar?.frame.height ?? 0.0)).isActive = true
        enrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        enrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        enrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func writeInfoView(type: PickerInfoType) -> EnrollWriteView {
        let title: String
        switch type {
        case .age: title = "나이가\n몇 살인가요?"
        case .height: title = "키가 얼마나 되나요?"
        case .weight: title = "체중은 얼마나\n되시나요?"
        }

        let writeView = EnrollWriteView(frame: view.frame, title: title, type: type)
        return writeView
    }

    private func configureUI() {

        self.navigationItem.rightBarButtonItem = skipButtonItem
        display(enrollView: genderEnrollView)
    }

    private func viewModelStepBind() {
        viewModel.step
            .bind { [weak self] value in
                guard let self = self
                else { return }
                let finalStep = 5

                self.infoStep = InfoStep.changeStep(number: value) ?? .age
                self.navigationItem.rightBarButtonItem = value >= finalStep ? nil : self.skipButtonItem

                if value < finalStep {
                    let view: EnrollWriteView
                    switch value {
                    case 2:
                        view = self.writeInfoView(type: .age)
                        view.pickerView.rx.itemSelected.bind { row, _ in
                            self.viewModel.age.onNext(row + view.lowerBound)
                        }.disposed(by: self.disposeBag)
                    case 3:
                        view = self.writeInfoView(type: .height)
                        view.pickerView.rx.itemSelected.bind { row, _ in
                            self.viewModel.height.onNext(row + view.lowerBound)
                        }.disposed(by: self.disposeBag)
                    default:
                        view = self.writeInfoView(type: .weight)
                        view.pickerView.rx.itemSelected.bind { row, _ in
                            self.viewModel.weight.onNext(row + view.lowerBound)
                        }.disposed(by: self.disposeBag)
                    }

                    view.nextButton.rx.tap.bind {
                        self.view.endEditing(true)
                        self.viewModel.step.onNext(value + 1)
                    }.disposed(by: self.disposeBag)
                    self.display(enrollView: view)
                } else {
                    self.display(enrollView: self.nickNameView)
                }
            }.disposed(by: disposeBag)
    }

    private func viewModelSavebind() {
        viewModel.save
            .bind { value in
                switch value {
                case true:
                    let userDefaultKey = "isUserInfoSaved"
                    let storyboardName = "Main"
                    let viewControllerName = "MainNavigationViewController"

                    UserDefaults.standard.set(true, forKey: userDefaultKey)
                    DispatchQueue.main.async {
                        let homeViewController = UIStoryboard(name: storyboardName, bundle: nil)
                            .instantiateViewController(withIdentifier: viewControllerName)
                        homeViewController.modalPresentationStyle = .fullScreen
                        self.present(homeViewController, animated: false)
                    }
                case false:
                    let title = "오류"
                    let message = "다시 시도해주시기 바랍니다."
                    let alertController: UIAlertController = .simpleAlert(title: title, message: message)
                    self.present(alertController, animated: true)
                }
            }.disposed(by: disposeBag)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

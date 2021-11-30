//
//  NotificationSettingViewController.swift
//  Booster
//
//  Created by mong on 2021/11/21.
//

import UIKit
import RxSwift

final class NotificationSettingViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var notificationImageView: UIImageView!
    @IBOutlet private weak var onOffButton: UIButton!

    // MARK: - Properties
    var viewModel = NotificationSettingViewModel()
    private let disposeBag = DisposeBag()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBarTitle()
        configureNotificationUI()
        bind()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: UIApplication.shared)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: UIApplication.shared)
    }

    // MARK: - @IBActions
    @IBAction private func onOffButtonDidTap(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString)
        else {
            let title = "오류"
            let message = "알 수 없는 오류로 인하여 알람 설정을 할 수 없어요"
            let alert = UIAlertController.simpleAlert(title: title, message: message)
            present(alert,
                    animated: true,
                    completion: nil)

            return
        }
        UIApplication.shared.open(url,
                                  options: [:],
                                  completionHandler: nil)
    }

    @IBAction private func backButtonDidTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - @objc
    @objc private func willEnterForeground(_ notification: NSNotification) {
        configureNotificationUI()
    }

    // MARK: - Functions
    private func configureNavigationBarTitle() {
        navigationItem.title = "알림 설정"
    }

    private func bind() {
        viewModel.model.asDriver()
            .drive(onNext: { [weak self] notificationSettingModel in
                self?.titleLabel.text = notificationSettingModel.title
                self?.subTitleLabel.text = notificationSettingModel.subTitle
                self?.notificationImageView.image = UIImage(named: notificationSettingModel.imageName)
                self?.onOffButton.backgroundColor = UIColor(named: notificationSettingModel.buttonBackgroundColorName)
                self?.onOffButton.setAttributedTitle(notificationSettingModel.buttonAttributedTitle, for: .normal)
                self?.onOffButton.tintColor = UIColor(named: notificationSettingModel.buttonTintColorName)
            }).disposed(by: disposeBag)
    }

    private func configureNotificationUI() {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings(completionHandler: { [weak self] (settings) in
            guard let self = self
            else { return }
            let status = settings.authorizationStatus

            if status == .authorized {
                self.viewModel.setState(to: .on)
                self.animateShaking(of: self.notificationImageView)
            } else if status == .denied {
                self.viewModel.setState(to: .off)
            }
        })
    }

    private func animateShaking(of view: UIImageView) {
        let rotateRatio = Double.pi / 12.0
        let duration = 0.10
        let repeatCount: Float = 3.0

        DispatchQueue.main.async {
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.fromValue = -rotateRatio
            animation.toValue = rotateRatio
            animation.duration = duration
            animation.autoreverses = true
            animation.repeatCount = repeatCount
            view.layer.add(animation, forKey: "ringingAnimation")
        }
    }
}

//
//  NotificationSettingViewController.swift
//  Booster
//
//  Created by mong on 2021/11/21.
//

import UIKit

final class NotificationSettingViewController: UIViewController {
    // MARK: - @IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet var notificationImageView: UIImageView!
    @IBOutlet private weak var onOffButton: UIButton!

    // MARK: - Properties

    // MARK: - Subscript

    // MARK: - Init

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureNotificationUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    // MARK: - @IBActions
    @IBAction func onOffButtonDidTap(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString)
        else {
            let alert = UIAlertController.simpleAlert(title: "오류", message: "알 수 없는 오류로 인하여 알람 설정을 할 수 없어요")
            present(alert, animated: true, completion: nil)

            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func backButtonDidTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - @objc
    @objc private func willEnterForeground(_ notification: NSNotification) {
        configureNotificationUI()
    }

    // MARK: - Functions
    private func configureNavigationBar() {
        navigationItem.title = "알림 설정"
    }

    private func configureNotificationUI() {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings(completionHandler: { [weak self] (settings) in
            let status = settings.authorizationStatus

            if status == .authorized {
                self?.configureNotificationOnUI()
            } else if status == .denied {
                self?.configureNotificationOffUI()
            }
        })
    }

    private func configureNotificationOffUI() {
        let title = "현재 알림이 꺼져있어요"
        let subTitle = "알람을 키면\n좋은 소식들을 가득 들려드릴게요"
        let buttonTitle = "알림 켜기"

        DispatchQueue.main.sync { [weak self] in
            self?.titleLabel.text = title
            self?.subTitleLabel.text = subTitle
            self?.notificationImageView.image = UIImage.notificationOff
            self?.onOffButton.backgroundColor = .boosterOrange
            self?.onOffButton.setAttributedTitle(NSAttributedString(string: buttonTitle), for: .normal)
            self?.onOffButton.tintColor = .boosterBlackLabel
        }
    }

    private func configureNotificationOnUI() {
        let title = "현재 알림이 켜져있어요"
        let subTitle = "좋은 소식들을\n들려드리기 위해 열심히 노력하고 있어요!"
        let buttonTitle = "알림 끄기"

        animateShaking(of: notificationImageView)
        DispatchQueue.main.sync { [weak self] in
            self?.titleLabel.text = title
            self?.subTitleLabel.text = subTitle
            self?.notificationImageView.image = UIImage.notificationOn
            self?.onOffButton.backgroundColor = .boosterEnableButtonGray
            self?.onOffButton.setAttributedTitle(NSAttributedString(string: buttonTitle), for: .normal)
            self?.onOffButton.tintColor = .boosterGray
        }
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

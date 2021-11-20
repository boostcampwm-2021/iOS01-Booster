//
//  EraseAllDataViewController.swift
//  Booster
//
//  Created by mong on 2021/11/17.
//

import UIKit

final class EraseAllDataViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet private weak var subTitleLabel: UILabel!

    // MARK: - Properties
    var viewModel: UserViewModel = UserViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationBarTitleConfigure()
        configureUI()
    }

    // MAKR: - @IBAction
    @IBAction private func eraseAllButtonDidTap(_ sender: Any) {
        viewModel.eraseAllData { [weak self] (result) in
            DispatchQueue.main.async {
                var alert = UIAlertController()
                switch result {
                case .success(let count):
                    let title = "삭제 완료"
                    let message = "총 \(count)개의 정보가 삭제됐어요!"
                    alert = UIAlertController.simpleAlert(title: title, message: message)
                case .failure(let error):
                    dump(error)
                    let title = "삭제 실패"
                    let message = "알 수 없는 오류로 인하여 정보를 삭제할 수 없어요"
                    alert = UIAlertController.simpleAlert(title: title, message: message)
                }
                self?.present(alert, animated: true) {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    @IBAction private func backButtonDidTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Functions
    private func navigationBarTitleConfigure() {
        title = "모든 데이터 지우기"
    }

    private func configureUI() {
        subTitleLabel.text = "산책에 대한 기록들은 \(viewModel.model.nickname)님의\n휴대폰에서만 소중하게 보관하고 있어요"
    }
}

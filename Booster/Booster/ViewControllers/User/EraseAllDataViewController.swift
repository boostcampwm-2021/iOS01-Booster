//
//  EraseAllDataViewController.swift
//  Booster
//
//  Created by mong on 2021/11/17.
//

import UIKit
import RxSwift

final class EraseAllDataViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet private weak var subTitleLabel: UILabel!

    // MARK: - Properties
    var viewModel: UserViewModel = UserViewModel()
    private let disposeBag = DisposeBag()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBarTitle()
        configureUI()
    }

    // MAKR: - @IBAction
    @IBAction private func eraseAllButtonDidTap(_ sender: UIButton) {
        var alert = UIAlertController()

        viewModel.eraseAllData()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                let title = "삭제 완료"
                let message = "모든 정보가 삭제됐어요!"
                alert = UIAlertController.simpleAlert(title: title,
                                                      message: message,
                                                      action: { (_) -> Void in
                    self.navigationController?.popViewController(animated: true)
                    return
                })
            }, onError: { _ in
                let title = "삭제 실패"
                let message = "알 수 없는 오류로 인하여 정보를 삭제할 수 없어요"
                alert = UIAlertController.simpleAlert(title: title, message: message)
            }, onCompleted: {
                self.present(alert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }

    @IBAction private func backButtonDidTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Functions
    private func configureNavigationBarTitle() {
        navigationItem.title = "모든 데이터 지우기"
    }

    private func configureUI() {
        subTitleLabel.text = "산책에 대한 기록들은 \(viewModel.model.nickname)님의\n휴대폰에서만 소중하게 보관하고 있어요"
    }
}

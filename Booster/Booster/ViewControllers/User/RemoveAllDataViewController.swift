//
//  RemoveAllDataViewController.swift
//  Booster
//
//  Created by mong on 2021/11/17.
//

import UIKit
import RxSwift

final class RemoveAllDataViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var cameraImageView: UIImageView!

    // MARK: - Properties
    var viewModel: UserViewModel
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

        configureNavigationBarTitle()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        repeatAnimationImage()
    }

    // MARK: - @IBAction
    @IBAction private func removeAllButtonDidTap(_ sender: UIButton) {
        var alert = UIAlertController()

        viewModel.removeAllData()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] isRemoved in
                guard let self = self
                else { return }
                
                if isRemoved {
                    let title = "삭제 완료"
                    let message = "모든 정보가 삭제됐어요!"
                    alert = self.popViewControllerAlertController(title: title, message: message)
                } else {
                    let title = "삭제 실패"
                    let message = "알 수 없는 오류로 인하여 삭제를 실패했어요"
                    alert = self.popViewControllerAlertController(title: title, message: message)
                }
                self.present(alert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }

    @IBAction private func backButtonDidTap(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Functions
    private func bind() {
        viewModel.model.asDriver()
            .drive(onNext: { [weak self] userInfo in
                guard let self = self
                else { return }

                let subTitle = "산책에 대한 기록들은 \(userInfo.nickname)님의\n휴대폰에서만 소중하게 보관하고 있어요"
                self.subTitleLabel.text = subTitle
            }).disposed(by: disposeBag)
    }
    
    private func repeatAnimationImage() {
        cameraImageView.layer.cornerRadius = 5
        UIView.transition(with: cameraImageView, duration: 2, options: [.repeat, .autoreverse, .curveEaseIn], animations: {
            self.cameraImageView.image = .cameraFill
            self.cameraImageView.backgroundColor = .boosterOrange
        }, completion: nil)
    }

    private func configureNavigationBarTitle() {
        navigationItem.title = "모든 데이터 지우기"
    }

    private func popViewControllerAlertController(title: String = "", message: String) -> UIAlertController {
        let alert = UIAlertController.simpleAlert(title: title,
                                              message: message,
                                              action: { (_) -> Void in
            self.navigationController?.popViewController(animated: true)
        })

        return alert
    }
}

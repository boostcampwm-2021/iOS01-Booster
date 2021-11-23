//
//  ModifyFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/17.
//

import UIKit
import RxSwift

protocol ModifyFeedViewControllerDelegate {
    func didModifyRecord()
}

final class ModifyFeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var contentTextView: UITextView!

    // MARK: - Properties
    var viewModel: ModifyFeedViewModel
    var delegate: ModifyFeedViewControllerDelegate?
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init?(coder: NSCoder, viewModel: ModifyFeedViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        bindUITapEvent()
        bindProperties()
    }

    // MARK: - Functions
    func configure() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료",
                                                            style: .done,
                                                            target: self,
                                                            action: nil)
        contentTextView.textContainer.lineFragmentPadding = 0
    }

    private func bindUITapEvent() {
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .bind { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)

        navigationItem.rightBarButtonItem?.rx.tap
            .bind { [weak self] _ in
                self?.viewModel.update()
            }
            .disposed(by: disposeBag)
    }

    private func bindProperties() {
        viewModel.writingRecord
            .map { $0.title }
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind(to: titleTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.writingRecord
            .map { $0.content }
            .take(1)
            .observe(on: MainScheduler.instance)
            .bind(to: contentTextView.rx.text)
            .disposed(by: disposeBag)

        titleTextField.rx.text
            .distinctUntilChanged()
            .map { $0 ?? "" }
            .bind { [weak self] newText in
                self?.viewModel.modifyTitle(newText)
            }
            .disposed(by: disposeBag)

        contentTextView.rx.text
            .distinctUntilChanged()
            .map { $0 ?? "" }
            .bind { [weak self] newText in
                self?.viewModel.modifyContent(newText)
            }
            .disposed(by: disposeBag)

        viewModel.isUpdated
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isUpdated in
                if isUpdated {
                    self?.delegate?.didModifyRecord()
                    self?.navigationController?.popViewController(animated: true)
                } else { self?.presentUpdateErrorController() }
            }
            .disposed(by: disposeBag)
    }

    private func presentUpdateErrorController() {
        let alertController: UIAlertController = .simpleAlert(title: "수정 오류", message: "수정하는 데 문제가 생겼습니다\n잠시 후 다시 시도해주세요")
        present(alertController, animated: true)
    }
}

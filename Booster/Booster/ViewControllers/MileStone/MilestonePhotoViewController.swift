//
//  MileStonePhotoViewController.swift
//  Booster
//
//  Created by mong on 2021/11/08.
//

import UIKit
import RxSwift
import RxCocoa

protocol MilestonePhotoViewControllerDelegate: AnyObject {
    func delete(milestone: Milestone)
}

class MilestonePhotoViewController: UIViewController, BaseViewControllerTemplate {
    typealias ViewModelType = MilestonePhotoViewModel

    // MARK: - Properties
    weak var delegate: MilestonePhotoViewControllerDelegate?
    var viewModel = MilestonePhotoViewModel(milestone: Milestone())
    private let disposeBag = DisposeBag()
    private lazy var mileStonePhotoImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: view.frame.width,
                                                  height: view.frame.height))
        imageView.image = UIImage(data: viewModel.milestone.imageData)
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()
    private lazy var deleteButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 50,
                                            height: 20))
        button.tintColor = .white
        button.setImage(UIImage.systemTrashFill, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                self?.delegate?.delete(milestone: self?.viewModel.milestone ?? Milestone())
            }.disposed(by: disposeBag)
        return button
    }()

    // MARK: - Init
    init(viewModel: MilestonePhotoViewModel) {
        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles
    override func viewDidLoad() {
        view.backgroundColor = .boosterBackground
        view.addSubview(mileStonePhotoImageView)
        view.addSubview(deleteButton)

        layoutConfig()
    }

    // MARK: - functions
    private func layoutConfig() {
        view.addConstraints([
            deleteButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

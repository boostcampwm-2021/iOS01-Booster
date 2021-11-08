//
//  MileStonePhotoViewController.swift
//  Booster
//
//  Created by mong on 2021/11/08.
//

import UIKit

class MileStonePhotoViewController: UIViewController {
    // MARK: - Enum

    // MARK: - @IBOutlet

    // MARK: - Variables
    private var mileStonePhotoViewModel: MileStonePhotoViewModel?
    private lazy var mileStonePhotoImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        imageView.image = UIImage(data: mileStonePhotoViewModel?.mileStone.imageData ?? Data())
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // MARK: - Subscript

    // MARK: - viewDidLoad or init
    init(viewModel: MileStonePhotoViewModel) {
        super.init(nibName: nil, bundle: nil)

        self.mileStonePhotoViewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(mileStonePhotoImageView)
    }
    // MARK: - @IBActions

    // MARK: - @objc

    // MARK: - functions
}

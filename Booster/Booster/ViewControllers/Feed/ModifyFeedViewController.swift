//
//  ModifyFeedViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/17.
//

import UIKit

class ModifyFeedViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum

    // MARK: - @IBOutlet

    // MARK: - Properties
    var viewModel = 0

    // MARK: - Subscript

    // MARK: - Init

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    // MARK: - @IBActions

    // MARK: - @objc
    @objc private func completedButtonDidTapped(_ sender: UIBarButtonItem) {
    }

    // MARK: - Functions
    func configure() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(completedButtonDidTapped(_:)))
    }
}

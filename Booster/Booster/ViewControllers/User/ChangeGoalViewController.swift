//
//  ChangeGoalViewController.swift
//  Booster
//
//  Created by mong on 2021/11/17.
//

import UIKit

class ChangeGoalViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var stepsTextField: UITextField!

    // MARK: - Properties
    var viewModel: GoalViewModel?
    var steps: Int = 10000

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        naivgationBarConfigure()
        UIConfigure()

        stepsTextField.delegate = self
        stepsTextField.becomeFirstResponder()
    }

    // MARK: - @IBActions
    @IBAction func backButtonDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func saveButtonDidTap(_ sender: Any) {

    }

    // MARK: - Functions
    private func naivgationBarConfigure() {

    }

    private func UIConfigure() {
        titleLabel.text = "현재 목표는\n\(steps) 걸음이에요\n얼마나 바꿔볼까요?"

        let border = CALayer()
        border.frame = CGRect(x: 0, y: stepsTextField.frame.size.height - 1, width: stepsTextField.frame.size.width, height: 1)
        border.backgroundColor = UIColor.boosterOrange.cgColor
        stepsTextField.layer.addSublayer(border)
        stepsTextField.layer.masksToBounds = true
    }
}

extension ChangeGoalViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text
        else { return true }
        
        let maxLength
        let length = text.count + string.count - range.length

        return length <= maxLength
    }
}

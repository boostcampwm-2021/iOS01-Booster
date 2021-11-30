//
//  BoosterTabBarViewController.swift
//  Booster
//
//  Created by hiju on 2021/11/30.
//
import HealthKit
import UIKit
import RxSwift

class BoosterTabBarViewController: UITabBarController, BaseViewControllerTemplate {
    // MARK: - Properties
    var viewModel = BoosterTabBarViewModel(usecase: BoosterTabBarUsecase())
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Functions
    func configure() {
        viewModel.requestHealthKitAccess()
    }
}

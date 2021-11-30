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
    var viewModel = 0
    
    // MARK: - Enum

    // MARK: - @IBOutlet

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    // MARK: - Subscript

    // MARK: - Init

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHealthKit()
    }
    
    // MARK: - @IBActions

    // MARK: - @objc

    // MARK: - Functions
    private func configureHealthKit() {
        guard let activeEnergyBurned = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
              let distanceWalkingRunning = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
              let stepCount = HKSampleType.quantityType(forIdentifier: .stepCount)
        else { return }

        let shareTypes = Set([activeEnergyBurned, distanceWalkingRunning, stepCount])
        let readTypes = Set([activeEnergyBurned, distanceWalkingRunning, stepCount])

        HealthKitManager.shared.requestAuthorization(shareTypes: shareTypes, readTypes: readTypes)
            .subscribe { _ in }
            .disposed(by: disposeBag)
    }
}

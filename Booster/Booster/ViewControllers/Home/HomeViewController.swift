import HealthKit
import UIKit

import RxSwift

final class HomeViewController: UIViewController {
    // MARK: - @IBOutlet
    @IBOutlet private weak var kcalLabel: UILabel!
    @IBOutlet private weak var timeActiveLabel: UILabel!
    @IBOutlet private weak var kmLabel: UILabel!
    @IBOutlet private weak var recordView: ThreeColumnRecordView!

    @IBOutlet private weak var todayTotalStepCountLabel: GradientLabel!
    @IBOutlet private weak var goalLabel: UILabel!
    @IBOutlet private weak var hourlyBarChartView: ChartView!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    // MARK: - Functions
    func configure() {
        configureHealthKit()
        bindHomeViewModel()
    }

    private func configureHealthKit() {
        guard let activeEnergyBurned = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
              let distanceWalkingRunning = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
              let stepCount = HKSampleType.quantityType(forIdentifier: .stepCount)
        else { return }

        let shareTypes = Set([activeEnergyBurned, distanceWalkingRunning, stepCount])
        let readTypes = Set([activeEnergyBurned, distanceWalkingRunning, stepCount])

        HealthStoreManager.shared.requestAuthorization(shareTypes: shareTypes, readTypes: readTypes) { isSuccess in
            if isSuccess {
                self.viewModel.fetchQueries()
            }
        }
    }

    private func bindHomeViewModel() {
        viewModel.homeModel
            .debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe({ [weak self] homeModel in
                guard let homeModel = homeModel.element
                else { return }

                self?.updateUI(using: homeModel)
            })
            .disposed(by: disposeBag)
    }

    private func updateUI(using homeModel: HomeModel) {
        guard let stepRatios = homeModel.stepRatios()
        else { return }
        if stepRatios.count == 0 { return }

        recordView.configureLabels(kcal: "\(homeModel.kcal)",
                                   time: homeModel.activeTime.stringToMinutesAndSeconds(),
                                   km: String(format: "%.2f", homeModel.km),
                                   timeLabelName: "time active")
        hourlyBarChartView.drawChart(stepRatios: stepRatios.map { CGFloat($0) }, strings: ["0", "6", "12", "18"])
        todayTotalStepCountLabel.drawLabel(step: homeModel.totalStepCount, ratio: homeModel.gradientRatio())
    }
}

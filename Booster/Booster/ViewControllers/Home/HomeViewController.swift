import HealthKit
import UIKit

import RxSwift

final class HomeViewController: UIViewController {
    // MARK: - @IBOutlet
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchQueries()
    }

    // MARK: - Functions
    func configure() {
        bindHomeViewModel()
    }

    private func bindHomeViewModel() {
        viewModel.homeModel.asDriver()
            .skip(4)
            .drive { [weak self] homeModel in
                self?.updateUI(using: homeModel)
                self?.viewModel.sendGoalNotification()
            }
            .disposed(by: disposeBag)
    }

    private func updateUI(using homeModel: HomeModel) {
        guard let stepRatios = homeModel.stepRatios()
        else { return }

        recordView.configureLabels(kcal: "\(homeModel.kcal)",
                                   time: homeModel.activeTime.stringToMinutesAndSeconds(),
                                   km: String(format: "%.2f", homeModel.km),
                                   timeLabelName: "time active")
        goalLabel.text = "\(homeModel.goal)"
        hourlyBarChartView.drawChart(stepRatios: stepRatios.map { CGFloat($0) }, strings: ["0", "6", "12", "18"])
        todayTotalStepCountLabel.drawLabel(step: homeModel.totalStepCount, ratio: homeModel.gradientRatio())
    }
}

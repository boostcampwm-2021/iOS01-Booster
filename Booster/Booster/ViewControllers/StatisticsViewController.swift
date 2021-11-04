import HealthKit
import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - @IBOutlet

    @IBOutlet private weak var weekButton: UIButton!
    @IBOutlet private weak var monthButton: UIButton!
    @IBOutlet private weak var yearButton: UIButton!
    @IBOutlet private weak var stepCountLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    @IBOutlet private weak var chartView: BarChartView!

    // MARK: - Variables

    private let viewModel = StatisticsViewModel()
    private let healthStore = HKHealthStore()

    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAuthorizationForStepCount()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateGraph(using: .week)
    }

    // MARK: - @IBActions

    @IBAction private func weekButtonDidTap(_ sender: UIButton) {
        self.weekButton.tintColor  = .white
        self.monthButton.tintColor = .gray
        self.yearButton.tintColor  = .gray
        self.updateGraph(using: .week)
    }

    @IBAction private func monthButtonDidTap(_ sender: UIButton) {
        self.weekButton.tintColor  = .gray
        self.monthButton.tintColor = .white
        self.yearButton.tintColor  = .gray
        self.updateGraph(using: .month)
    }

    @IBAction private func yearButtonDidTap(_ sender: UIButton) {
        self.weekButton.tintColor  = .gray
        self.monthButton.tintColor = .gray
        self.yearButton.tintColor  = .white
        self.updateGraph(using: .year)

    }

    // MARK: - functions

    private func requestAuthorizationForStepCount() {
        guard let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        HealthStoreManager.shared.requestAuthorization(shareTypes: [stepCount], readTypes: [stepCount]) { result in
            if result {
                self.viewModel.queryStepCount()
            }
        }
    }

    private func updateGraph(using buttonType: Button) {
        self.chartView.statisticsCollection = self.viewModel.statistics(for: buttonType)
        self.stepCountLabel.text = String(self.chartView.statisticsCollection.averageStatistics())
    }
}

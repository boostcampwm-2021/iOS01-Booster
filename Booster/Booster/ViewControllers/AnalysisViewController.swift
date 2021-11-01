import HealthKit
import UIKit

final class AnalysisViewController: UIViewController {

  // MARK: - @IBOutlet

  @IBOutlet private weak var weekButton: UIButton!
  @IBOutlet private weak var monthButton: UIButton!
  @IBOutlet private weak var yearButton: UIButton!
  @IBOutlet private weak var stepCountLabel: UILabel!

  // MARK: - Variables

  private let viewModel = AnalysisViewModel()

  private var healthStore = HKHealthStore()
  private var query: HKStatisticsCollectionQuery?

  // MARK: - ViewController Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
      self.viewModel.tappedButton.bind { _ in

      switch self.viewModel.tappedButton.value {
      case .week:
        self.updateGraph()
      case .month:
        self.updateGraph()
      case .year:
        self.updateGraph()
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

    self.healthStore.requestAuthorization(toShare: [stepCountType], read: [stepCountType]) { success, error in
      guard error != nil,
            success else { return }

    }
  }

  // MARK: - @IBActions

  @IBAction private func weekButtonDidTap(_ sender: UIButton) {
    self.weekButton.tintColor  = .white
    self.monthButton.tintColor = .gray
    self.yearButton.tintColor  = .gray
    self.viewModel.updateTappedButton(.week)
  }

  @IBAction private func monthButtonDidTap(_ sender: UIButton) {
    self.weekButton.tintColor  = .gray
    self.monthButton.tintColor = .white
    self.yearButton.tintColor  = .gray
    self.viewModel.updateTappedButton(.month)
  }

  @IBAction private func yearButtonDidTap(_ sender: UIButton) {
    self.weekButton.tintColor  = .gray
    self.monthButton.tintColor = .gray
    self.yearButton.tintColor  = .white
    self.viewModel.updateTappedButton(.year)
  }

  // MARK: - functions

  private func updateGraph() {
    DispatchQueue.main.async {

    }
  }

}

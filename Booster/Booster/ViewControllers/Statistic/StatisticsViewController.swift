import HealthKit
import UIKit

final class StatisticsViewController: UIViewController, BaseViewControllerTemplate {
    typealias Duration = StatisticsViewModel.Duration
    typealias ViewModelType = StatisticsViewModel

    // MARK: - @IBOutlet
    @IBOutlet private weak var weekButton: UIButton!
    @IBOutlet private weak var monthButton: UIButton!
    @IBOutlet private weak var yearButton: UIButton!
    @IBOutlet private weak var averageStepCountLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    @IBOutlet private weak var intervalLabel: UILabel!
    @IBOutlet private weak var stepCountLabel: UILabel!

    @IBOutlet private weak var chartView: ChartView!

    // MARK: - Properties
    private let sideInset: CGFloat = 20
    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .boosterLabel
        view.frame = .zero
        return view
    }()

    var viewModel = StatisticsViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(barView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAuthorizationForStepCount()
        bindViewModel()
        viewModel.selectedDuration.value = .week
        addGestures()
    }

    // MARK: - @IBActions
    @IBAction private func weekButtonDidTap(_ sender: UIButton) {
        weekButton.tintColor  = UIColor.boosterLabel
        monthButton.tintColor = .gray
        yearButton.tintColor  = .gray
        viewModel.selectedDuration.value = .week
        viewModel.selectedStatistics.value = (index: nil, coordinate: nil)
    }

    @IBAction private func monthButtonDidTap(_ sender: UIButton) {
        weekButton.tintColor  = .gray
        monthButton.tintColor = UIColor.boosterLabel
        yearButton.tintColor  = .gray
        viewModel.selectedDuration.value = .month
        viewModel.selectedStatistics.value = (index: nil, coordinate: nil)
    }

    @IBAction private func yearButtonDidTap(_ sender: UIButton) {
        weekButton.tintColor  = .gray
        monthButton.tintColor = .gray
        yearButton.tintColor  = UIColor.boosterLabel
        viewModel.selectedDuration.value = .year
        viewModel.selectedStatistics.value = (index: nil, coordinate: nil)
    }

    // MARK: - functions
    private func addGestures() {
        chartView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chartViewDidTap(_:))))
        chartView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(chartViewDidPan(_:))))
    }

    private func requestAuthorizationForStepCount() {
        guard let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        HealthStoreManager.shared.requestAuthorization(shareTypes: [stepCount], readTypes: [stepCount]) { [weak self] success in
            if success {
                self?.viewModel.queryStepCount()
            }
        }
    }

    private func bindViewModel() {
        viewModel.selectedDuration.bind { [weak self] duration in
            self?.updateUI(using: duration)
        }

        viewModel.selectedStatistics.bind { [weak self] data in
            self?.updateUI(index: data.index, coordinate: data.coordinate)
        }
    }

    private func updateUI(using duration: Duration) {
        let statisticsCollection: StatisticsCollection = viewModel.statistics()
        let stepRatios: [CGFloat] = configureStepRatios(using: statisticsCollection, for: duration)
        let strings: [String] = configureBottomStrings(using: statisticsCollection, for: duration)

        chartView.drawChart(stepRatios: stepRatios, strings: strings)
        averageStepCountLabel.text = String(statisticsCollection.averageStatistics())
        switch duration {
        case .week:
            dateLabel.text = statisticsCollection.termOfStatistics(component: .day)
        case .month:
            dateLabel.text = statisticsCollection.termOfStatistics(component: .weekOfYear)
        case .year:
            dateLabel.text = statisticsCollection.termOfStatistics(component: .month)
        }
    }

    private func updateUI(index: Int?, coordinate: Float?) {
        guard let index = index,
              let coordinate = coordinate,
              let maxStep = viewModel.statistics().maxStatistics()?.step
        else {
            stepCountLabel.text = String()
            intervalLabel.text = String()
            barView.frame = .zero
            return
        }

        let statistics: Statistics = viewModel.statistics()[index]

        let xCoordinate = CGFloat(coordinate) * chartView.frame.width + sideInset
        let stepRatio = 1 - CGFloat(statistics.step) / CGFloat(maxStep)

        stepCountLabel.text = "\(statistics.step)걸음"
        stepCountLabel.sizeToFit()
        stepCountLabel.center.x = xCoordinate

        intervalLabel.text = stepInterval(from: statistics.date)
        intervalLabel.sizeToFit()
        intervalLabel.center.x = xCoordinate

        barView.frame = CGRect(x: xCoordinate,
                               y: view.frame.height - chartView.frame.height - view.safeAreaInsets.bottom,
                               width: 1,
                               height: chartView.topSpace + chartView.centerSpace * stepRatio)

        stepCountLabel.frame.origin.x = max(stepCountLabel.frame.origin.x, sideInset)
        stepCountLabel.frame.origin.x = min(stepCountLabel.frame.origin.x, view.frame.width - stepCountLabel.frame.width - sideInset)

        intervalLabel.frame.origin.x = max(intervalLabel.frame.origin.x, sideInset)
        intervalLabel.frame.origin.x = min(intervalLabel.frame.origin.x, view.frame.width - intervalLabel.frame.width - sideInset)
    }

    private func configureStepRatios(using statisticsCollection: StatisticsCollection, for duration: Duration) -> [CGFloat] {
        guard let maxStep = statisticsCollection.maxStatistics()?.step
        else { return [CGFloat]() }

        var stepRatios = [CGFloat]()

        for statistics in statisticsCollection.statistics() {
            let step: Int = statistics.step
            let stepRatio = CGFloat(step) / CGFloat(maxStep)
            stepRatios.append(stepRatio)
        }

        return stepRatios
    }

    private func configureBottomStrings(using statisticsCollection: StatisticsCollection, for duration: Duration) -> [String] {
        let dateFormatter: DateFormatter = dateFormatter(for: duration)
        var strings = [String]()

        for statistics in statisticsCollection.statistics() {
            let date: Date = statistics.date
            let string: String = dateFormatter.string(from: date)
            strings.append(string)
        }

        return strings
    }

    private func dateFormatter(for duration: Duration) -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_KR")

        switch duration {
        case .week:
            dateformatter.dateFormat = "E"
        case .month:
            dateformatter.dateFormat = "d"
        case .year:
            dateformatter.dateFormat = "MMM"
        }

        return dateformatter
    }

    private func stepInterval(from date: Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_KR")
        dateformatter.dateFormat = "yy.MM.dd"

        var endDate: Date? = Date()
        switch viewModel.selectedDuration.value {

        case .week:
            return dateformatter.string(from: date)
        case .month:
            endDate = Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: date)
        case .year:
            endDate = Calendar.current.date(byAdding: .month, value: 1, to: date)
        }

        guard let endDate = endDate
        else { return String() }

        return "\(dateformatter.string(from: date)) - \(dateformatter.string(from: endDate))"
    }

    // MARK: - @objc
    @objc private func chartViewDidTap(_ sender: UITapGestureRecognizer) {
        let xCoordinate = sender.location(in: chartView).x
        guard (0..<chartView.frame.width).contains(xCoordinate)
        else { return }

        viewModel.tapStatistics(at: Float(xCoordinate / chartView.frame.width))
    }

    @objc private func chartViewDidPan(_ sender: UIPanGestureRecognizer) {
        let xCoordinate = sender.location(in: chartView).x
        guard (0..<chartView.frame.width).contains(xCoordinate)
        else { return }

        viewModel.panStatistics(at: Float(xCoordinate / chartView.frame.width))
    }
}

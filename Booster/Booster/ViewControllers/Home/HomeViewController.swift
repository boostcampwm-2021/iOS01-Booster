import HealthKit
import UIKit
import RxSwift

final class HomeViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    private enum Opacity {
        static let zero: Float = 0
        static let one: Float = 1
    }

    // MARK: - @IBOutlet
    @IBOutlet private weak var kcalLabel: UILabel!
    @IBOutlet private weak var timeActiveLabel: UILabel!
    @IBOutlet private weak var kmLabel: UILabel!
    @IBOutlet private weak var todayTotalStepCountLabel: UILabel!
    @IBOutlet private weak var goalLabel: UILabel!
    @IBOutlet private weak var hourlyBarChartView: ChartView!

    // MARK: - Properties
    var viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    private let todayHoursContant = 25

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

    private func configureTotalStepCountLabelGradient(current: Double, goal: Double) {
        let labelSize = 70.0
        let ratio = (current * labelSize / goal) / 100 + 0.25
        let gradient = gradientLayer(ratio: [NSNumber(value: ratio), NSNumber(value: ratio)],
                                     bounds: todayTotalStepCountLabel.bounds,
                                     colors: [UIColor.boosterOrange.cgColor, UIColor.boosterLabel.cgColor])
        todayTotalStepCountLabel.textColor = gradientColor(gradientLayer: gradient)
    }

    private func bindHomeViewModel() {
        viewModel.homeModel
            .debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe({ [weak self] value in
                if let model = value.element {
                    self?.configureLabels(model)
                }
                return
            })
            .disposed(by: disposeBag)
    }

    private func configureLabels(_ value: HomeModel) {
        todayTotalStepCountLabel.text = "\(value.totalStepCount)"
        kmLabel.text = String(format: "%.2f", value.km)
        kcalLabel.text = "\(value.kcal)"
        timeActiveLabel.text = value.activeTime.stringToMinutesAndSeconds()
        todayTotalStepCountLabel.layer.opacity = Opacity.zero
        configureTotalStepCountLabelGradient(current: Double(value.totalStepCount), goal: 10000)
        configureHourlyChartView()

        UIView.animate(withDuration: 2) {
            self.todayTotalStepCountLabel.layer.opacity = Opacity.one
        }
    }

    private func configureHourlyChartView() {
        let stepRatios: [CGFloat] = configureStepRatios(using: viewModel.homeModel.value.hourlyStatistics)
        var strings = [String](repeating: "", count: todayHoursContant)
        for (index, _) in strings.enumerated() {
            if index % 6 == 0 {
                strings[index] = "\(index)"
            }
        }

        hourlyBarChartView.drawChart(stepRatios: stepRatios, strings: strings)
    }

    private func configureStepRatios(using statisticsCollection: StatisticsCollection) -> [CGFloat] {
        guard let maxStep = statisticsCollection.maxStatistics()?.step
        else { return [CGFloat](repeating: 0, count: todayHoursContant) }

        if maxStep == 0 { return [CGFloat](repeating: 0, count: todayHoursContant) }

        var stepRatios = [CGFloat]()
        for statistics in statisticsCollection.statistics() {
            let step: Int = statistics.step
            let stepRatio = CGFloat(step) / CGFloat(maxStep)
            stepRatios.append(stepRatio)
        }

        if stepRatios.count < todayHoursContant {
            stepRatios += [CGFloat](repeating: 0, count: todayHoursContant - stepRatios.count)
        }
        return stepRatios
    }

    private func gradientLayer(ratio: [NSNumber],
                               bounds: CGRect,
                               colors: [CGColor]) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors
        gradient.locations = ratio
        gradient.startPoint = CGPoint(x: 0.5, y: 1)
        gradient.endPoint = CGPoint(x: 0.5, y: 0)
        return gradient
    }

    private func gradientColor(gradientLayer: CAGradientLayer) -> UIColor {
        UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, 0.0)
        guard let currentContext = UIGraphicsGetCurrentContext()
        else { return .boosterLabel }
        gradientLayer.render(in: currentContext)
        guard let image = UIGraphicsGetImageFromCurrentImageContext()
        else { return .boosterLabel }
        UIGraphicsEndImageContext()

        return UIColor(patternImage: image)
    }
}

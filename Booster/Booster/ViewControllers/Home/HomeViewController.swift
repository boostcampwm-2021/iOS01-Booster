import HealthKit
import UIKit

final class HomeViewController: UIViewController {

    // MARK: Properties

    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var timeActiveLabel: UILabel!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var todayTotalStepCountLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!

    private var homeViewModel = HomeViewModel()

    // MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHealthKit()
        bindHomeViewModel()
    }

}

// MARK: - Setting UI

extension HomeViewController {

    private func configureHealthKit() {
        guard let activeEnergyBurned   = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
           let distanceWalkingRunning = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
           let stepCount       = HKSampleType.quantityType(forIdentifier: .stepCount) else { return }
        let shareTypes = Set([activeEnergyBurned, distanceWalkingRunning, stepCount])
        let readTypes = Set([activeEnergyBurned, distanceWalkingRunning, stepCount])

        HealthStoreManager.shared.requestAuthorization(shareTypes: shareTypes, readTypes: readTypes) { isSuccess in
            if isSuccess {
                self.homeViewModel.fetchQueries()
            }
        }
    }

    private func configureTotalStepCountLabelGradient(current: Double, goal: Double) {
        let labelSize = 70.0
        let ratio = (current * labelSize / goal) / 100 + 0.25
        let gradient = gradientLayer(ratio: [NSNumber(value: ratio), NSNumber(value: ratio)], bounds: todayTotalStepCountLabel.bounds, colors: [#colorLiteral(red: 1, green: 0.3607843137, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1).cgColor])
        todayTotalStepCountLabel.textColor = gradientColor(gradientLayer: gradient)
    }

    private func bindHomeViewModel() {
        homeViewModel.homeData.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.todayTotalStepCountLabel.text = "\(value.totalStepCount)"
                self?.kmLabel.text = String(format: "%.2f", value.km)
                self?.kcalLabel.text = "\(value.kcal)"
                self?.timeActiveLabel.text = value.activeTime.stringToMinutesAndSeconds()
                self?.todayTotalStepCountLabel.layer.opacity = 0
                self?.configureTotalStepCountLabelGradient(current: Double(value.totalStepCount), goal: 10000)
                UIView.animate(withDuration: 2) {
                    self?.todayTotalStepCountLabel.layer.opacity = 1
                }
            }
        }
    }

    private func gradientLayer(ratio: [NSNumber], bounds: CGRect, colors: [CGColor]) -> CAGradientLayer {
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
        guard let currentContext = UIGraphicsGetCurrentContext() else { return .white }
        gradientLayer.render(in: currentContext)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return .white }
        UIGraphicsEndImageContext()

        return UIColor(patternImage: image)
    }

}

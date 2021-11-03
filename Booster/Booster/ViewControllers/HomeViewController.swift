import HealthKit
import UIKit

final class HomeViewController: UIViewController {

    // MARK: Properties

    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var timeActiveLabel: UILabel!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var todayTotalStepCountLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var stepCountGraphView: CurveGraphView!

    private var homeViewModel = HomeViewModel()

    // MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        // requestHealthKitAuthorization()
        bindHomeViewModel()
    }

}

// MARK: - Setting UI

extension HomeViewController {

    private func configureTotalStepCountLabelGradient(current: Double, goal: Double) {
        let gradient = gradientLayer(bounds: todayTotalStepCountLabel.bounds, colors: ratioGradientColor(current: current, goal: goal))
        todayTotalStepCountLabel.textColor = gradientColor(gradientLayer: gradient)
    }

    private func bindHomeViewModel() {
        homeViewModel.homeData.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.todayTotalStepCountLabel.text = "\(value.totalStepCount)"
                self?.kmLabel.text = "\(value.km)"
                self?.kcalLabel.text = "\(value.kcal)"
                self?.timeActiveLabel.text = value.activeTime.stringToMinutesAndSeconds()
                self?.todayTotalStepCountLabel.layer.opacity = 0
                self?.configureTotalStepCountLabelGradient(current: Double(value.totalStepCount), goal: 10000)
                self?.stepCountGraphView.dataEntries = value.hourlyStepCount
                self?.stepCountGraphView.dataLabels = ["0", "6", "12", "18", "24"]
                UIView.animate(withDuration: 2) {
                    self?.todayTotalStepCountLabel.layer.opacity = 1
                }
            }
        }
    }

    private func ratioGradientColor(current: Double, goal: Double) -> [CGColor] {
        let currentRatio = Int(current / goal * 100) > 100 ? 100 : Int(current / goal * 100)
        let whiteColors = [CGColor](repeating: #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1).cgColor, count: 100 - currentRatio)
        let orangeColors = [CGColor](repeating: #colorLiteral(red: 1, green: 0.3607843137, blue: 0, alpha: 1).cgColor, count: currentRatio)

        return whiteColors + orangeColors
    }

    private func gradientLayer(bounds: CGRect, colors: [CGColor]) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
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

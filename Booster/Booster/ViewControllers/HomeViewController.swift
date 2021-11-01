import UIKit

class HomeViewController: UIViewController {

    // MARK: Properties

    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var timeActiveLabel: UILabel!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var todayTotalStepCountLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!

    // MARK: Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

}

extension HomeViewController {

    private func configure() {
        let gradient = gradientLayer(bounds: todayTotalStepCountLabel.bounds, colors: ratioGradientColor(current: 8000, goal: 10000))
        todayTotalStepCountLabel.textColor = gradientColor(gradientLayer: gradient)
    }

    func ratioGradientColor(current: Double, goal: Double) -> [CGColor] {
        let currentRatio = Int(current / goal * 10)
        let whiteColors = [CGColor](repeating: UIColor.white.cgColor, count: 10 - currentRatio)
        let orangeColors = [CGColor](repeating: UIColor.orange.cgColor, count: currentRatio)

        return whiteColors + orangeColors
    }

    func gradientLayer(bounds: CGRect, colors: [CGColor]) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        return gradient
    }

    func gradientColor(gradientLayer: CAGradientLayer) -> UIColor {
        UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, 0.0)

        guard let currentContext = UIGraphicsGetCurrentContext() else { return .white }
        gradientLayer.render(in: currentContext)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return .white }
        UIGraphicsEndImageContext()

        return UIColor(patternImage: image)
    }

}

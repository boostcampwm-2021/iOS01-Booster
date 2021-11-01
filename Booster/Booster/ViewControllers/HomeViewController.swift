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
        
    }

}

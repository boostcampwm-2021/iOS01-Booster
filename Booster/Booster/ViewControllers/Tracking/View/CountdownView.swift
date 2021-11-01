import Foundation
import UIKit

class CountdownView: UIView {
    private var countdown = 3
    private lazy var countdownLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: self.center.y, width: 10, height: 10))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(countdown)"
        label.font = .bazaronite(size: 150)
        label.textColor = UIColor(red: 255/255, green: 92/255, blue: 0/255, alpha: 1)

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        UIConfig()
        layoutConfig()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        UIConfig()
        layoutConfig()
    }

    func start() {
        if countdown == 0 { return }
        countdownLabel.frame = CGRect(x: 0, y: self.center.y, width: 10, height: 10)
        countdownLabel.text = "\(countdown)"

        UIView.animate(withDuration: 0.5, delay: 0,
                       options: .curveEaseIn,
                       animations: { [unowned self] in
//            countdownLabel.font = .bazaronite(size: 200)
            countdownLabel.transform = CGAffineTransform(translationX: self.bounds.midX, y: 0)
//            countdownLabel.transform = countdownLabel.transform.scaledBy(x: 2, y: 2)
        },
                       completion: { [unowned self] _ in
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
//                countdownLabel.font = .bazaronite(size: 100)
                countdownLabel.transform = CGAffineTransform(translationX: self.bounds.maxX, y: 0)
//                countdownLabel.transform = countdownLabel.transform.scaledBy(x: 1, y: 1)
            }, completion: { [unowned self] _ in
                countdown -= 1
                start()
            })
        })
    }

    private func UIConfig() {
        backgroundColor = .black
        addSubview(countdownLabel)
    }

    private func layoutConfig() {
        NSLayoutConstraint(item: countdownLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
}

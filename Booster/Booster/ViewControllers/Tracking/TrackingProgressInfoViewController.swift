import UIKit
import CoreLocation
import MapKit

class TrackingProgressInfoViewController: UIViewController {
    private var manager: CLLocationManager = CLLocationManager()
    private var startLocation: CLLocation?
    private var lastLocation: CLLocation?
    private var distance: Double = 0.0
    private var timer: Timer = Timer()
    private var date: Date = Date()

    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultLabel()
        locationAuth()

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(trackingTimer), userInfo: nil, repeats: true)
    }

    private func defaultLabel() {
        let timeContent = makeTimerText(second: 0, minute: 0, hour: 0)
        let kcalContent = "0\n"
        let distanceContent = "0\n"
        let kcalTitle = "kcal"
        let timeTitle = "time"
        let distaceTitle = "km"

        kcalLabel.attributedText = makeAttributedText(content: kcalContent, title: kcalTitle)
        timeLabel.attributedText = makeAttributedText(content: timeContent, title: timeTitle)
        distanceLabel.attributedText = makeAttributedText(content: distanceContent, title: distaceTitle)
    }

    private func locationAuth() {
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            DispatchQueue.main.async { [weak self] in
                self?.manager.startUpdatingLocation()
                self?.manager.startMonitoringSignificantLocationChanges()
            }
            manager.distanceFilter = 10
        }
    }

    private func makeTimerText(second: Int, minute: Int, hour: Int) -> String {
        var text = ""
        text += "\(hour == 0 ? "" : "\(hour < 10 ? "0\(hour): " : "\(hour):")")"
        text += "\(minute < 10 ? "0\(minute)'" : "\(minute)'")"
        text += "\(second < 10 ? "0\(second)\"\n" : "\(second)\"\n")"
        return text
    }

    private func makeAttributedText(content: String, title: String) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString()

        let contentText: NSAttributedString = .makeAttributedString(text: content, font: .bazaronite(size: 35), color: .black)
        let titleText: NSAttributedString = .makeAttributedString(text: title, font: .notoSansKR(.light, 15), color: .black)

        [contentText, titleText].forEach {
            mutableString.append($0)
        }

        return mutableString
    }

    @objc
    private func trackingTimer() {
        let time = -Int(date.timeIntervalSinceNow)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        let content = makeTimerText(second: seconds, minute: minutes, hour: hours)
        let title = "time"
        timeLabel.attributedText = makeAttributedText(content: content, title: title)
    }
}

extension TrackingProgressInfoViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let start = startLocation {
            lastLocation = locations.last

            guard let last = lastLocation else {
                return
            }

            startLocation = lastLocation
            distance += start.distance(from: last)

            let title = "km"
            let content = "\(String.init(format: "%.1f", distance/1000))\n"

            distanceLabel.attributedText = makeAttributedText(content: content, title: title)
        } else {
            startLocation = locations.first
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
}

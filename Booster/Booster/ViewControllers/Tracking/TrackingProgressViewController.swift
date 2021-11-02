import UIKit
import MapKit
import CoreLocation
import CoreMotion

class TrackingProgressViewController: UIViewController {
    enum Color {
        static let orange = UIColor.init(red: 1.0, green: 0.332, blue: 0.0, alpha: 1)
    }

    enum Image {
        static let pause = UIImage(systemName: "pause")
        static let camera = UIImage(systemName: "camera")
        static let stop = UIImage(systemName: "stop")
        static let play = UIImage(systemName: "play")
    }

    private var time: Int = 0
    private var distance: Double = 0.0
    private var isPause: Bool = false
    private var timer: Timer = Timer()
    private var startDate: Date = Date()
    private var manager: CLLocationManager = CLLocationManager()
    private var startLocation: CLLocation?
    private var lastLocation: CLLocation?
    private lazy var imagePickerController: UIImagePickerController = {
       let pickerController = UIImagePickerController()
        pickerController.sourceType = .camera
        pickerController.allowsEditing = true
        pickerController.cameraDevice = .rear
        pickerController.cameraCaptureMode = .photo
        pickerController.delegate = self
        return pickerController
    }()
    private let pedometer = CMPedometer()

    @IBOutlet weak var mapView: TrackingMapView!
    @IBOutlet weak var pedometerLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var infoView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        locationAuth()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        pedometer.startUpdates(from: Date()) { [weak self ] (data, _) in
            if let data = data {
                print("\(data.numberOfSteps)")
                DispatchQueue.main.async {
                    self?.pedometerLabel.text = "\(data.numberOfSteps.intValue)"
                }
            } else {
                print("## error")
            }
        }
    }

    private func configure() {
        let timeContent = makeTimerText(second: 0, minute: 0)
        let kcalContent = "0\n"
        let distanceContent = "0\n"
        let kcalTitle = "kcal"
        let timeTitle = "time"
        let distaceTitle = "km"
        let radius: CGFloat = 50

        pedometerLabel.font = .bazaronite(size: 60)
        pedometerLabel.textColor = .black
        kcalLabel.attributedText = makeAttributedText(content: kcalContent, title: kcalTitle)
        timeLabel.attributedText = makeAttributedText(content: timeContent, title: timeTitle)
        distanceLabel.attributedText = makeAttributedText(content: distanceContent, title: distaceTitle)

        leftButton.layer.borderWidth = 1
        leftButton.layer.borderColor = UIColor.black.cgColor
        leftButton.layer.cornerRadius = radius
        rightButton.layer.cornerRadius = radius

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(trackingTimer), userInfo: nil, repeats: true)
        mapView.delegate = self
    }

    private func update() {
        [distanceLabel, timeLabel, kcalLabel].forEach {
            $0?.textColor = self.isPause ? .black : .white
        }

        infoView.backgroundColor = isPause ? Color.orange : .black
        rightButton.backgroundColor = isPause ? .black : Color.orange
        leftButton.backgroundColor = isPause ? Color.orange : .black
        leftButton.layer.borderColor = isPause ? UIColor.black.cgColor : Color.orange.cgColor
        leftButton.tintColor = isPause ? .black : Color.orange
        rightButton.tintColor = isPause ? Color.orange : .black
        rightButton.setImage(isPause ? Image.pause : Image.play, for: .normal)
        leftButton.setImage(isPause ? Image.camera : Image.stop, for: .normal)
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

    private func makeTimerText(second: Int, minute: Int) -> String {
        var text = ""
        text += "\(minute < 10 ? "0\(minute)'" : "\(minute)'")"
        text += "\(second < 10 ? "0\(second)\"\n" : "\(second)\"\n")"
        return text
    }

    private func makeAttributedText(content: String, title: String) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString()

        let contentText: NSAttributedString = .makeAttributedString(text: content, font: .bazaronite(size: 30), color: .black)
        let titleText: NSAttributedString = .makeAttributedString(text: title, font: .notoSansKR(.light, 15), color: .black)

        [contentText, titleText].forEach {
            mutableString.append($0)
        }

        return mutableString
    }

    @IBAction func leftTouchUp(_ sender: UIButton) {
        switch isPause {
        case false:
            present(imagePickerController, animated: true)
        case true:
            break
        }
    }

    @IBAction func rightTouchUp(_ sender: Any) {
        update()
        isPause.toggle()
        switch isPause {
        case false:
            startDate = Date()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(trackingTimer), userInfo: nil, repeats: true)
            DispatchQueue.main.async { [weak self] in
                self?.manager.startUpdatingLocation()
                self?.manager.startMonitoringSignificantLocationChanges()
            }
        case true:
            self.time -= Int(startDate.timeIntervalSinceNow)
            startLocation = nil
            timer.invalidate()
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }

    @objc
    private func trackingTimer() {
        let time = -Int(startDate.timeIntervalSinceNow) + self.time
        let seconds = time % 60
        let minutes = (time / 60) % 60

        let timeContent = makeTimerText(second: seconds, minute: minutes)
        let timeTitle = "time"
        let kcalContent = "\(Int(60 / 15 * 0.9 * Double(minutes)))\n"
        let kcalTitle = "kcal"

        timeLabel.attributedText = makeAttributedText(content: timeContent, title: timeTitle)
        kcalLabel.attributedText = makeAttributedText(content: kcalContent, title: kcalTitle)
    }
}

extension TrackingProgressViewController: CLLocationManagerDelegate {
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

extension TrackingProgressViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var circleRenderer = CircleRenderer()
        if let overlay = overlay as? MKCircle {
            circleRenderer = CircleRenderer(circle: overlay)
        }
        guard let polyLine = overlay as? MKPolyline else {
            return MKPolylineRenderer()
        }

        let polyLineRenderer = MKPolylineRenderer(polyline: polyLine)

        polyLineRenderer.strokeColor = UIColor(red: 255/255, green: 92/255, blue: 0/255, alpha: 1)
        polyLineRenderer.lineWidth = 8

        return polyLineRenderer
    }
}

extension TrackingProgressViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            print(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

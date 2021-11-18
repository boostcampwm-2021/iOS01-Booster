import UIKit
import MapKit
import HealthKit
import CoreMotion

class TrackingProgressViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    enum NibName: String {
        case photoAnnotationView = "PhotoAnnotationView"
    }

    enum Identifier {
        enum Annotation: String {
            case milestone = "milestone"
        }
    }

    // MARK: - @IBOutlet
    @IBOutlet weak var mapView: TrackingMapView!
    @IBOutlet weak var pedometerLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var pedometerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pedometerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var kcalTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonBottomConstraint: NSLayoutConstraint!

    // MARK: - Properties
    private let pedometer = CMPedometer()
    var viewModel: TrackingProgressViewModel = TrackingProgressViewModel()
    private var lastestTime: Int = 0
    private let startDate = Date()
    private var timerDate = Date()
    private var timer = Timer()
    private var manager: CLLocationManager = CLLocationManager()
    private lazy var imagePickerController: UIImagePickerController = {
       let pickerController = UIImagePickerController()
        pickerController.sourceType = .camera
        pickerController.allowsEditing = true
        pickerController.cameraDevice = .rear
        pickerController.cameraCaptureMode = .photo
        pickerController.delegate = self
        return pickerController
    }()
    private lazy var titleTextField: UITextField = {
        let textField = UITextField(frame: self.view.frame)
        let title = "제목"
        textField.font = .notoSansKR(.medium, 25)
        textField.textColor = .boosterLabel
        textField.attributedPlaceholder = .makeAttributedString(text: title,
                                                                font: .notoSansKR(.medium, 25),
                                                                color: .lightGray)
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        let emptyText = "오늘 산책은 어땠나요?"
        textView.backgroundColor = .clear
        textView.font = .notoSansKR(.light, 17)
        textView.text = emptyText
         textView.textColor = .lightGray
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        return textView
    }()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - @IBActions
    @IBAction func leftTouchUp(_ sender: UIButton) {
        switch viewModel.state {
        case .start:
            guard let currentLatitude = manager.location?.coordinate.latitude,
                  let currentLongitude = manager.location?.coordinate.longitude,
                  let imageData = UIImage(systemName: "camera")?.pngData()
            else { return }

            if viewModel.isMileStoneExistAt(latitude: currentLatitude, longitude: currentLongitude) {
                let title = "추가 실패"
                let message = "이미 다른 마일스톤이 존재합니다\n작성한 마일스톤을 제거해주세요"
                let alert = UIAlertController.simpleAlert(title: title, message: message)
                present(alert, animated: true, completion: nil)

                return
            }

            #if targetEnvironment(simulator)
            let mileStone = MileStone(latitude: currentLatitude,
                                      longitude: currentLongitude,
                                      imageData: imageData)
            viewModel.append(milestone: mileStone)
            #else
            present(imagePickerController, animated: true)
            #endif
        default:
            viewModel.recordEnd()
            stopAnimation()
        }
    }

    @IBAction func rightTouchUp(_ sender: Any) {
        switch viewModel.state {
        case .end:
            let title = "저장 오류"
            let message = "저장하기 위해서는 건강앱의 권한이 필요해요"
            let store = HKHealthStore()
            let alert = UIAlertController.simpleAlert(title: title, message: message)
            var types: Set<HKQuantityType> = []

            HealthQuantityType.allCases.forEach {
                if let type = $0.quantity {
                    types.insert(type)
                }
            }

            if HKHealthStore.isHealthDataAvailable() {
                makeImageData()
            } else {
                store.requestAuthorization(toShare: types, read: types) { success, error in
                    if let _ = error {
                        self.present(alert, animated: true)
                    } else if success {
                        self.makeImageData()
                    } else {
                        self.present(alert, animated: true)
                    }
                }
            }
        default:
            viewModel.toggle()
            update()
        }
    }

    // MARK: - @objc
    @objc private func trackingTimer() {
        var isMoved = true
        let timerTime = -Int(timerDate.timeIntervalSinceNow)
        let time = timerTime + lastestTime
        let limit: Double = 300

        pedometer.queryPedometerData(from: Date(timeIntervalSinceNow: -limit), to: Date()) { data, _ in
            guard let data = data, let distance = data.distance?.intValue
            else { return }
            isMoved = distance > 5
        }

        switch isMoved && timerTime <= Int(limit) {
        case true:
            viewModel.update(seconds: time)
        case false:
            viewModel.toggle()
            update()
        }
    }

    @objc private func touchBackButton(_ sender: UIBarButtonItem) {
        let title = "되돌아가기"
        let message = "현재 기록 상황이 다 지워집니다\n정말로 되돌아가실 건가요?"
        let alertViewController: UIAlertController = .alert(title: title,
                                              message: message,
                                              success: { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alertViewController, animated: true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            view.frame.origin.y == 0 {
            view.frame.origin.y = -keyboardSize.height
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
            view.setNeedsLayout()
        }
    }

    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    func configure() {
        let radius: CGFloat = 50
        let backButton = UIBarButtonItem(image: .systemArrowLeft,
                                         style: .plain,
                                         target: self,
                                         action: #selector(touchBackButton(_:)))
        backButton.tintColor = .boosterBlackLabel
        leftButton.layer.borderWidth = 1
        leftButton.layer.borderColor = UIColor.boosterBackground.cgColor
        leftButton.layer.cornerRadius = radius
        rightButton.layer.cornerRadius = radius
        pedometerLabel.font = .bazaronite(size: 60)
        pedometerLabel.textColor = .boosterBlackLabel

        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(trackingTimer),
                                     userInfo: nil,
                                     repeats: true)
        [mapView, kcalLabel, timeLabel, distanceLabel, pedometerLabel, rightButton].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButton

        mapView.delegate = self
        manager.delegate = self
        configureNotifications()
        locationAuth()
        bind()
    }

    private func bind() {
        viewModel.trackingModel.bind { [weak self] model in
            guard let self = self else {
                return
            }
            self.updatePedometer()
            self.configure(model: model)
        }

        viewModel.milestones.bind({ [weak self] milestones in
            guard let milestone = milestones.last,
                  let latitude = milestone.coordinate.latitude,
                  let longitude = milestone.coordinate.longitude
            else { return }
            self?.mapView.addMileStoneAnnotation(latitude: latitude, longitude: longitude)
        })
    }

    private func configure(model: TrackingModel) {
        let timeContent = makeTimerText(time: model.seconds)
        let kcalContent = "\(model.calories)\n"
        let distanceContent = "\(String.init(format: "%.1f", model.distance/1000))\n"
        let stepsTitle = "\(viewModel.state == .end ? " steps" : "")"
        let kcalTitle = "kcal"
        let timeTitle = "time"
        let distanceTitle = "km"
        let stepsColor: UIColor = viewModel.state == .end ? .boosterOrange : .boosterBlackLabel
        let color: UIColor = viewModel.state == .start ? .boosterBackground : .boosterLabel

        pedometerLabel.attributedText = makeAttributedText(content: "\(model.steps)",
                                                           title: stepsTitle,
                                                           contentFont: .bazaronite(size: 60),
                                                           titleFont: .notoSansKR(.regular, 20),
                                                           color: stepsColor)
        kcalLabel.attributedText = makeAttributedText(content: kcalContent, title: kcalTitle, color: color)
        timeLabel.attributedText = makeAttributedText(content: timeContent, title: timeTitle, color: color)
        distanceLabel.attributedText = makeAttributedText(content: distanceContent, title: distanceTitle, color: color)
    }

    private func update() {
        let isStart: Bool = viewModel.state == .start
        [distanceLabel, timeLabel, kcalLabel].forEach {
            $0?.textColor = isStart ? .boosterBackground : .boosterLabel
        }

        infoView.backgroundColor = isStart ? .boosterOrange : .boosterBackground
        rightButton.backgroundColor = isStart ? .boosterBackground : .boosterOrange
        leftButton.backgroundColor = isStart ? .boosterOrange : .boosterBackground
        leftButton.layer.borderColor = isStart ? UIColor.boosterBackground.cgColor : UIColor.boosterOrange.cgColor
        leftButton.tintColor = isStart ? .boosterBackground : .boosterOrange
        rightButton.tintColor = isStart ? .boosterOrange : .boosterBackground
        rightButton.setImage(isStart ? .systemPause : .systemPlay, for: .normal)
        leftButton.setImage(isStart ? .systemCamera : .systemStop, for: .normal)
        timerDate = isStart ? Date() : timerDate

        switch isStart {
        case true:
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(trackingTimer),
                                         userInfo: nil,
                                         repeats: true)
            locationAuth()
        case false:
            lastestTime = viewModel.trackingModel.value.seconds
            viewModel.update(seconds: lastestTime)
            timer.invalidate()
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
            pedometer.stopUpdates()
        }
    }

    private func configureWrite() {
        infoView.addSubview(titleTextField)
        infoView.addSubview(contentTextView)
        titleTextField.topAnchor.constraint(equalTo: kcalLabel.bottomAnchor, constant: 40).isActive = true
        titleTextField.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -25).isActive = true
        titleTextField.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 25).isActive = true
        contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10).isActive = true
        contentTextView.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -10).isActive = true
        contentTextView.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -25).isActive = true
        contentTextView.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 25).isActive = true
    }

    private func locationAuth() {
        if CLLocationManager.locationServicesEnabled() {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            DispatchQueue.main.async { [weak self] in
                guard let self = self
                else { return }

                self.manager.startUpdatingLocation()
                self.manager.startMonitoringSignificantLocationChanges()

                if let location = self.manager.location {
                    self.mapView.setRegion(to: location)
                }
            }
            updatePedometer()
            manager.distanceFilter = 1
        }
    }

    private func updatePedometer() {
        pedometer.queryPedometerData(from: startDate, to: Date()) { [weak self] data, _ in
            guard let self = self,
                  let data = data
            else { return }

            self.viewModel.update(steps: data.numberOfSteps.intValue)
        }
    }

    private func stopAnimation() {
        self.leftButton.isHidden = true
        UIView.animate(withDuration: 1, animations: { [weak self] in
            guard let self = self,
                  let content = self.pedometerLabel.text
            else { return }

            let title = " steps"
            self.rightButtonWidthConstraint.constant = 70
            self.rightButtonHeightConstraint.constant = 70
            self.rightButton.layer.cornerRadius = 35
            self.rightButtonTrailingConstraint.constant = 25
            self.rightButtonBottomConstraint.constant = 25
            self.mapViewBottomConstraint.constant = self.view.frame.maxY - 290
            self.pedometerTrailingConstraint.constant = self.view.frame.maxX - 230
            self.pedometerTopConstraint.constant = 20
            [self.timeTopConstraint, self.kcalTopConstraint, self.distanceTopConstraint].forEach {
                $0.constant = 130
            }
            self.rightButton.setImage(.systemPencil, for: .normal)
            self.pedometerLabel.attributedText = self.makeAttributedText(content: content,
                                                                         title: title,
                                                                         contentFont: .bazaronite(size: 60),
                                                                         titleFont: .notoSansKR(.regular, 20),
                                                                         color: .boosterOrange)
            self.view.layoutIfNeeded()
            self.infoView.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let self = self
            else { return }

            self.configureWrite()
            self.infoView.bringSubviewToFront(self.rightButton)
        })
    }

    private func makeTimerText(time: Int) -> String {
        let seconds = time % 60
        let minutes = time / 60
        var text = ""
        text += "\(minutes < 10 ? "0\(minutes)'" : "\(minutes)'")"
        text += "\(seconds < 10 ? "0\(seconds)\"\n" : "\(seconds)\"\n")"
        return text
    }

    private func makeAttributedText(content: String,
                                    title: String,
                                    contentFont: UIFont = .bazaronite(size: 30),
                                    titleFont: UIFont = .notoSansKR(.light, 15),
                                    color: UIColor = .black)
    -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString()

        let contentText: NSAttributedString = .makeAttributedString(text: content,
                                                                    font: contentFont,
                                                                    color: color)
        let titleText: NSAttributedString = .makeAttributedString(text: title,
                                                                  font: titleFont,
                                                                  color: color)

        [contentText, titleText].forEach {
            mutableString.append($0)
        }

        return mutableString
    }

    private func makeImageData() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let center = self.viewModel.centerCoordinateOfPath()
            else { return }

            let coordinates = self.viewModel.coordinates()

            self.mapView.snapShotImageOfPath(backgroundColor: .clear,
                                             coordinates: coordinates,
                                             center: center,
                                             range: self.viewModel.distance()) { image in
                guard let data = image?.pngData()
                else {
                    self.save()
                    return
                }
                self.viewModel.update(imageData: data)
                self.save()
            }
        }
    }

    private func save() {
        if let centerCoordinate = viewModel.centerCoordinateOfPath() {
            let coordinates = viewModel.coordinates()
            mapView.snapShotImageOfPath(coordinates: coordinates,
                                        center: centerCoordinate,
                                        range: viewModel.distance()) { [weak self] (image) in
                if let imageData = image?.pngData() {
                    self?.viewModel.update(imageData: imageData)
                }
            }
        }

        viewModel.save { error in
            guard error == nil
            else { return }

            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: CLLocation Manager Delegate
extension TrackingProgressViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last
        else { return }

        let currentCoordinate = currentLocation.coordinate

        guard let latestCoordinate = viewModel.latestCoordinate(),
              let prevLatitude = latestCoordinate.latitude,
              let prevLongitude = latestCoordinate.longitude
        else {
            let coordinate = Coordinate(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            viewModel.append(coordinate: coordinate)
            return
        }
        let prevCoordinate = CLLocationCoordinate2D(latitude: prevLatitude, longitude: prevLongitude)
        let latestLocation = CLLocation(latitude: prevLatitude, longitude: prevLongitude)

        mapView.updateUserLocationOverlay(location: currentLocation)
        if viewModel.state == .start { mapView.drawPath(from: prevCoordinate, to: currentCoordinate) }

        viewModel.update(distance: latestLocation.distance(from: currentLocation))
        viewModel.append(coordinate: Coordinate(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let error = error as? CLError
        if error?.code == .denied && error?.code == .deferredFailed {
            let title = "GPS 오류"
            let message = "GPS 권한 확인 또는 GPS기능을 다시 연결 해주시기 바랍니다."
            let alertController: UIAlertController = .simpleAlert(title: title, message: message)

            viewModel.toggle()
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
            present(alertController, animated: true)
        }
    }
}

// MARK: MKMap View Deleagate
extension TrackingProgressViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = CircleRenderer(circle: overlay)

            return circleRenderer
        }

        if let polyLine = overlay as? MKPolyline {
            let polyLineRenderer = MKPolylineRenderer(polyline: polyLine)
            polyLineRenderer.strokeColor = .boosterOrange
            polyLineRenderer.lineWidth = 8

            return polyLineRenderer
        }

        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        mapView.view(for: mapView.userLocation)?.isEnabled = false
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Identifier.Annotation.milestone.rawValue)
        annotationView?.canShowCallout = false
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Identifier.Annotation.milestone.rawValue)

            guard let customView = UINib(nibName: NibName.photoAnnotationView.rawValue, bundle: nil).instantiate(withOwner: self, options: nil).first as? PhotoAnnotationView,
                  let mileStone = viewModel.milestones.value.last
            else { return nil }

            customView.frame.origin.x = customView.frame.origin.x - customView.frame.width / 2.0
            customView.frame.origin.y = customView.frame.origin.y - customView.frame.height
            annotationView!.frame.origin.x = annotationView!.frame.origin.x - customView.frame.width / 2.0
            annotationView!.frame.origin.y = annotationView!.frame.origin.y - customView.frame.height

            customView.photoImageView.image = UIImage(data: mileStone.imageData)
            customView.photoImageView.backgroundColor = .white

            annotationView!.addSubview(customView)
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation { return }

        mapView.deselectAnnotation(view.annotation, animated: false)
        let coordinate = Coordinate(latitude: view.annotation?.coordinate.latitude, longitude: view.annotation?.coordinate.longitude)
        guard let selectedMileStone = viewModel.mileStone(at: coordinate)
        else { return }

        let mileStonePhotoViewModel = MileStonePhotoViewModel(mileStone: selectedMileStone)
        let mileStonePhotoVC = MileStonePhotoViewController(viewModel: mileStonePhotoViewModel)
        mileStonePhotoVC.viewModel = mileStonePhotoViewModel
        mileStonePhotoVC.delegate = self

        present(mileStonePhotoVC, animated: true, completion: nil)
    }
}

extension TrackingProgressViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let currentLatitude = manager.location?.coordinate.latitude,
                  let currentLongitude = manager.location?.coordinate.longitude,
                  let imageData = image.pngData()
            else { return }

            let mileStone = MileStone(latitude: currentLatitude,
                                      longitude: currentLongitude,
                                      imageData: imageData)
            viewModel.append(milestone: mileStone)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: text view delegate
extension TrackingProgressViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .boosterLabel
        }
        rightButton.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            let emptyText = "오늘 산책은 어땠나요?"
            textView.text = emptyText
            textView.textColor = .lightGray
        }
        rightButton.isHidden = false
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        viewModel.write(content: textView.text)
    }
}

// MARK: text field delegate
extension TrackingProgressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let title = textField.text
        else { return }
        viewModel.write(title: title)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        rightButton.isHidden = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        rightButton.isHidden = false
    }
}

// MARK: mile stone photo view controller delegate
extension TrackingProgressViewController: MileStonePhotoViewControllerDelegate {
    func delete(mileStone: MileStone) {
        if let _ = viewModel.remove(of: mileStone), mapView.removeMileStoneAnnotation(of: mileStone) {
            let title = "삭제 완료"
            let message = "마일스톤을 삭제했어요"
            let alertViewController = UIAlertController.simpleAlert(title: title, message: message)
            present(alertViewController, animated: true)
        }
    }
}

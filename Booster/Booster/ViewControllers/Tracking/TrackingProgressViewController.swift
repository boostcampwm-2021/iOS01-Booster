import UIKit
import MapKit
import CoreMotion
import RxSwift
import RxCocoa

final class TrackingProgressViewController: UIViewController, BaseViewControllerTemplate {
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
    private let startDate = Date()
    private var lastestTime: Int = 0
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
        textField.rx.controlEvent([.editingDidEnd])
            .bind {
                self.rightButton.isHidden = false
            }.disposed(by: disposeBag)
        textField.rx.controlEvent([.editingDidBegin])
            .bind {
                self.rightButton.isHidden = true
            }.disposed(by: disposeBag)
        textField.rx.text
            .distinctUntilChanged()
            .skip(1)
            .bind { [weak self] value in
                guard let text = value
                else { return }

                self?.viewModel.title.onNext(text)
            }.disposed(by: disposeBag)
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
        textView.rx.text
            .distinctUntilChanged()
            .skip(1)
            .bind { [weak self] value in
                guard let text = value
                else { return }

                self?.viewModel.content.onNext(text)
            }.disposed(by: disposeBag)
        textView.delegate = self
        return textView
    }()
    private lazy var backButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem()
        buttonItem.image = .systemArrowLeft
        buttonItem.tintColor = .boosterBlackLabel
        buttonItem.rx.tap
            .throttle(.milliseconds(800), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] in
                let title = "되돌아가기"
                let message = "현재 기록 상황이 다 지워집니다\n정말로 되돌아가실 건가요?"
                let alertViewController: UIAlertController = .alert(title: title,
                                                      message: message,
                                                      success: { _ in
                    self?.navigationController?.popViewController(animated: true)
                })
                self?.present(alertViewController, animated: true)
            }.disposed(by: disposeBag)
        return buttonItem
    }()
    private lazy var userLocationButton: MKUserTrackingButton = {
        let button = MKUserTrackingButton(mapView: mapView)
        button.backgroundColor = .boosterLabel
        button.layer.masksToBounds = true
        button.tintColor = UIColor.boosterOrange
        button.layer.cornerRadius = button.bounds.width/2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let disposeBag = DisposeBag()
    var viewModel: TrackingProgressViewModel = TrackingProgressViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = true
        manager.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        manager.stopUpdatingLocation()
        tabBarController?.tabBar.isHidden = false
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
            viewModel.seconds.onNext(time)
        case false:
            viewModel.state.accept(viewModel.state.value == .start ? .pause : .start)
        }
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
        view.addSubview(userLocationButton)
        leftButton.layer.borderWidth = 1
        leftButton.layer.borderColor = UIColor.boosterBackground.cgColor
        leftButton.layer.cornerRadius = radius
        rightButton.layer.cornerRadius = radius
        pedometerLabel.font = .bazaronite(size: 60)
        pedometerLabel.textColor = .boosterBlackLabel
        userLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        userLocationButton.bottomAnchor.constraint(equalTo: infoView.topAnchor, constant: -20).isActive = true

        [mapView, kcalLabel, timeLabel, distanceLabel, pedometerLabel, rightButton].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButtonItem

        mapView.delegate = self
        configureNotifications()
        bindViewModel()
        bindView()
        locationAuth()
    }

    private func bindView() {
        leftButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] _ in
                guard let self = self
                else { return }

                switch self.viewModel.state.value {
                case .start:
                    guard let currentLatitude = self.manager.location?.coordinate.latitude,
                          let currentLongitude = self.manager.location?.coordinate.longitude,
                          let imageData = UIImage(systemName: "camera")?.pngData()
                    else { return }

                    self.viewModel.mileStone(at: Coordinate(latitude: currentLatitude, longitude: currentLongitude))
                        .observe(on: MainScheduler.asyncInstance)
                        .subscribe { [weak self] value in
                            guard let element = value.element, let _ = element
                            else {
                                #if targetEnvironment(simulator)
                                let milestone = Milestone(latitude: currentLatitude,
                                                          longitude: currentLongitude,
                                                          imageData: imageData)
                                self?.viewModel.addMilestones.onNext([milestone])
                                #else
                                self?.present(self?.imagePickerController ?? UIImagePickerController(), animated: true)
                                #endif

                                return
                            }

                            let title = "추가 실패"
                            let message = "이미 다른 마일스톤이 존재합니다\n작성한 마일스톤을 제거해주세요"
                            let alert: UIAlertController = .simpleAlert(title: title, message: message)
                            self?.present(alert, animated: true, completion: nil)

                        }.disposed(by: self.disposeBag)
                default:
                    self.viewModel.state.accept(.end)
                }
            }.disposed(by: disposeBag)

        rightButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] _ in
                guard let self = self
                else { return }

                switch self.viewModel.state.value {
                case .end:
                    self.makeImageData()
                default:
                    self.viewModel.state.accept(self.viewModel.state.value == .start ? .pause : .start)
                }
            }.disposed(by: disposeBag)
    }

    private func bindViewModel() {
        viewModel.state
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] value in
                if value != .end { self?.update() } else { self?.stopAnimation() }
            }.disposed(by: disposeBag)

        viewModel.tracking
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] value in
                self?.configure(model: value)
            }.disposed(by: disposeBag)

        viewModel.addMilestones.bind { [weak self] milestones in
            guard let milestone = milestones.last,
                  let latitude = milestone.coordinate.latitude,
                  let longitude = milestone.coordinate.longitude
            else { return }
            self?.mapView.addMilestoneAnnotation(latitude: latitude, longitude: longitude)
        }.disposed(by: disposeBag)

        viewModel.saveResult
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] error in
            guard error == nil
            else { return }

            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }

    private func configure(model: TrackingModel) {
        let timeContent = makeTimerText(time: model.seconds)
        let kcalContent = "\(model.calories)\n"
        let distanceContent = "\(String.init(format: "%.1f", model.distance/1000))\n"
        let stepsTitle = "\(viewModel.state.value == .end ? " steps" : "")"
        let kcalTitle = "kcal"
        let timeTitle = "time"
        let distanceTitle = "km"
        let stepsColor: UIColor = viewModel.state.value == .end ? .boosterOrange : .boosterBlackLabel
        let color: UIColor = viewModel.state.value == .start ? .boosterBackground : .boosterLabel

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
        let isStart: Bool = viewModel.state.value == .start
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
            lastestTime = viewModel.tracking.value.seconds
            viewModel.seconds.onNext(lastestTime)
            timer.invalidate()
            manager.stopUpdatingLocation()
            pedometer.stopUpdates()
            pedometer.stopEventUpdates()
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
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            DispatchQueue.main.async { [weak self] in
                guard let self = self
                else { return }
                self.manager.allowsBackgroundLocationUpdates = true
                self.manager.startUpdatingLocation()

                if let location = self.manager.location {
                    self.viewModel.coordinates.onNext([Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)])
                    self.mapView.setRegion(to: location)
                }
            }
            updatePedometer()
            manager.distanceFilter = 1
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func updatePedometer() {
        pedometer.queryPedometerData(from: startDate, to: Date()) { [weak self] data, _ in
            guard let self = self,
                  let data = data
            else { return }

            self.viewModel.steps.onNext(data.numberOfSteps.intValue)
        }
    }

    private func stopAnimation() {
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
        manager.stopUpdatingLocation()
        manager.stopMonitoringSignificantLocationChanges()
        pedometer.stopUpdates()
        leftButton.isHidden = true
        userLocationButton.isHidden = true
        UIView.animate(withDuration: 1, animations: { [weak self] in
            guard let self = self
            else { return }

            let title = " steps"
            let content = "\(self.viewModel.tracking.value.steps)"
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
        guard let center = self.viewModel.centerCoordinateOfPath()
        else { return }

        let coordinates = self.viewModel.tracking.value.coordinates

        self.mapView.snapShotImageOfPath(backgroundColor: .clear,
                                         coordinates: coordinates,
                                         center: center,
                                         range: self.viewModel.tracking.value.distance) { image in
            self.viewModel.imageData.onNext(image?.pngData() ?? Data())
            self.viewModel.save()
        }
    }
}

// MARK: CLLocation Manager Delegate
extension TrackingProgressViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last
        else { return }
        print(locations, "locations")
        print(viewModel.tracking.value.distance, "distance")
        let currentCoordinate = currentLocation.coordinate

        guard let latestCoordinate = viewModel.latestCoordinate(),
              let prevLatitude = latestCoordinate.latitude,
              let prevLongitude = latestCoordinate.longitude
        else {
            let coordinate = Coordinate(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            viewModel.coordinates.onNext([coordinate])
            return
        }
        let prevCoordinate = CLLocationCoordinate2D(latitude: prevLatitude, longitude: prevLongitude)
        let latestLocation = CLLocation(latitude: prevLatitude, longitude: prevLongitude)

        if viewModel.state.value == .start { mapView.drawPath(from: prevCoordinate, to: currentCoordinate) }

        viewModel.distance.onNext(latestLocation.distance(from: currentLocation))
        let coordinate = Coordinate(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        viewModel.coordinates.onNext([coordinate])
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let error = error as? CLError
        if error?.code == .denied && error?.code == .deferredFailed {
            let title = "GPS 오류"
            let message = "GPS 권한 확인 또는 GPS기능을 다시 연결 해주시기 바랍니다."
            let alertController: UIAlertController = .simpleAlert(title: title, message: message)

            viewModel.state.accept(viewModel.state.value == .start ? .pause : .start)
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
            present(alertController, animated: true)
        }
    }
}

// MARK: MKMap View Deleagate
extension TrackingProgressViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
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
                  let mileStone: Milestone = viewModel.tracking.value.milestones.last
            else { return nil }

            customView.photoImageView.image = UIImage(data: mileStone.imageData)
            customView.photoImageView.backgroundColor = .white

            annotationView = customView
            annotationView?.centerOffset = CGPoint(x: 0, y: -customView.frame.height / 2.0)
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation { return }

        mapView.deselectAnnotation(view.annotation, animated: false)
        let coordinate = Coordinate(latitude: view.annotation?.coordinate.latitude, longitude: view.annotation?.coordinate.longitude)

        viewModel.mileStone(at: coordinate)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] value in
                guard let self = self,
                      let element = value.element,
                      let selectedMileStone = element
                else { return }

                let milestonePhotoViewModel = MilestonePhotoViewModel(milestone: selectedMileStone)
                let milestonePhotoVC = MilestonePhotoViewController(viewModel: milestonePhotoViewModel)
                milestonePhotoVC.viewModel = milestonePhotoViewModel
                milestonePhotoVC.delegate = self

                self.present(milestonePhotoVC, animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
}

extension TrackingProgressViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let currentLatitude = manager.location?.coordinate.latitude,
                  let currentLongitude = manager.location?.coordinate.longitude,
                  let imageData = image.pngData()
            else { return }

            let milestone = Milestone(latitude: currentLatitude,
                                      longitude: currentLongitude,
                                      imageData: imageData)
            viewModel.addMilestones.onNext([milestone])
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
}

// MARK: text field delegate
extension TrackingProgressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: mile stone photo view controller delegate
extension TrackingProgressViewController: MilestonePhotoViewControllerDelegate {
    func delete(milestone: Milestone) {
        viewModel.remove(of: milestone)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { value in
                if let value = value.element,
                    value && self.mapView.removeMilestoneAnnotation(of: milestone) {
                    let title = "삭제 완료"
                    let message = "마일스톤을 삭제했어요"
                    let alertViewController: UIAlertController = .simpleAlert(title: title, message: message)
                    self.present(alertViewController, animated: true)
                }
            }.disposed(by: disposeBag)
    }
}

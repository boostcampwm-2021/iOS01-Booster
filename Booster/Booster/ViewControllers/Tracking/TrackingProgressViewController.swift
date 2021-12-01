import UIKit
import MapKit
import Network
import CoreMotion
import RxSwift
import RxCocoa

final class TrackingProgressViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet weak var mapView: TrackingMapView!
    @IBOutlet weak var infoView: TrackingInfoView!
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!

    // MARK: - Properties
    private let pedometer = CMPedometer()
    private let monitor = NWPathMonitor()
    private var pedomterSteps: Int = 0
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
    private lazy var backButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem()
        buttonItem.image = .systemArrowLeft
        buttonItem.tintColor = .boosterBlackLabel
        buttonItem.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - @objc
    @objc private func trackingTimer() {
        var isMoved = true
        let timerTime = -Int(timerDate.timeIntervalSinceNow)
        let time = timerTime + lastestTime
        let limit: Double = 300

        if CMPedometer.authorizationStatus() == .authorized {
            pedometer.queryPedometerData(from: Date(timeIntervalSinceNow: -limit), to: Date()) { data, _ in
                guard let data = data, let distance = data.distance?.intValue
                else { return }
                isMoved = distance > 5
            }

            pedometer.queryPedometerData(from: timerDate, to: Date()) { [weak self] data, _ in
                guard let data = data
                else { return }

                self?.viewModel.steps.onNext(data.numberOfSteps.intValue + (self?.pedomterSteps ?? 0))
            }
        } else {
            viewModel.state.accept(.pause)

            let title = "동작 및 피트니스"
            let content = "걸음 수 기록을 위해 동작 및 피트니스를 설정 앱에서 권한을 허용해주시기 바랍니다."
            let alertController: UIAlertController = .simpleAlert(title: title, message: content)

            present(alertController, animated: true)
        }

        switch isMoved && timerTime <= Int(limit) {
        case true:
            viewModel.seconds.onNext(time)
        case false:
            viewModel.state.accept(viewModel.state.value == .start ? .pause : .start)
        }
    }

    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func configure() {
        view.addSubview(userLocationButton)
        userLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        userLocationButton.bottomAnchor.constraint(equalTo: infoView.topAnchor, constant: -20).isActive = true

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButtonItem

        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 1
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()

        configureNotifications()
        bindViewModel()
        bindView()
        startMonitor()
    }

    private func configureNotifications() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification, object: nil)
            .map { notification -> CGFloat in
                return (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0.0
            }.asDriver(onErrorJustReturn: 0.0)
            .drive(onNext: { [weak self] value in
                guard let self = self
                else { return }

                let viewY = self.view.frame.origin.y
                self.view.frame.origin.y = viewY == 0 ? -value : viewY
            },
                   onCompleted: nil,
                   onDisposed: nil)
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification, object: nil)
            .map { notification -> CGFloat in
                return (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 10.0
            }.asDriver(onErrorJustReturn: 10.0)
            .drive(onNext: { [weak self] _ in
                guard let self = self
                else { return }

                self.view.frame.origin.y = 0
                self.view.setNeedsLayout()
            },
                   onCompleted: nil,
                   onDisposed: nil)
            .disposed(by: disposeBag)
    }

    private func bindView() {
        infoView.titleTextField.rx.text
            .distinctUntilChanged()
            .skip(1)
            .bind { [weak viewModel] value in
                guard let text = value
                else { return }

                viewModel?.title.onNext(text)
            }.disposed(by: disposeBag)
        infoView.contentTextView.rx.text
            .distinctUntilChanged()
            .skip(1)
            .bind { [weak self] value in
                guard let text = value,
                      let textColor = self?.infoView.contentTextView.textColor
                else { return }

                if textColor != .lightGray {
                    self?.viewModel.content.onNext(text)
                }
            }.disposed(by: disposeBag)
        infoView.leftButton.rx.tap
            .throttle(.microseconds(1500), scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                guard let self = self
                else { return }
                
                self.infoView.leftButton.bounceAnimate()

                switch self.viewModel.state.value {
                case .start:
                    guard let currentLatitude = self.manager.location?.coordinate.latitude,
                          let currentLongitude = self.manager.location?.coordinate.longitude,
                          let imageData = UIImage(systemName: "camera")?.pngData()
                    else { return }

                    let currentCoordinate = Coordinate(latitude: currentLatitude, longitude: currentLongitude)
                    if let _ = self.viewModel.trackingModel.value.milestones.milestone(at: currentCoordinate) {
                        let title = "추가 실패"
                        let message = "이미 다른 마일스톤이 존재합니다\n작성한 마일스톤을 제거해주세요"
                        let alertController: UIAlertController = .simpleAlert(title: title, message: message)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        #if targetEnvironment(simulator)
                        let milestone = Milestone(latitude: currentLatitude,
                                                  longitude: currentLongitude,
                                                  imageData: imageData)
                        self.viewModel.append(of: milestone)
                        #else
                        self.present(self.imagePickerController, animated: true)
                        #endif
                    }
                default:
                    let title = "기록 종료"
                    let content = "기록을 종료하고 저장 단계로 넘어가시겠습니까?"
                    let alertController: UIAlertController = .alert(title: title,
                                                                    message: content,
                                                                    success: { _ in
                        self.viewModel.state.accept(.end)
                    })

                    self.present(alertController, animated: true)
                }
            }.disposed(by: disposeBag)

        infoView.rightButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                guard let self = self
                else { return }

                self.infoView.rightButton.bounceAnimate()
                
                switch self.viewModel.state.value {
                case .end:
                    self.infoView.rightButton.isUserInteractionEnabled = false
                    self.makeImageData()
                default:
                    let status = CLLocationManager.authorizationStatus()
                    if CMPedometer.authorizationStatus() == .authorized
                        && CLLocationManager.locationServicesEnabled()
                        && status != .denied
                        && status != .notDetermined
                        && status != .restricted {
                        self.viewModel.state.accept(self.viewModel.state.value == .start ? .pause : .start)
                    } else {
                        let title = "동작/피트니스 및 위치 권한"
                        let content = "걸음 수 기록 및 위치 정보 수집을 위해 설정 앱에서 권한을 확인 해주시기 바랍니다."
                        let alertController: UIAlertController = .simpleAlert(title: title, message: content)

                        self.present(alertController, animated: true)
                    }
                }
            }.disposed(by: disposeBag)
    }

    private func bindViewModel() {
        viewModel.state
            .asDriver()
            .drive(onNext: { [weak self] trackingState in
                if trackingState != .end {
                    self?.update()
                } else {
                    self?.viewModel.address(observable: self?.locationToAddress() ?? Observable<String>.empty())
                    self?.stopAnimation()
                }
            }).disposed(by: disposeBag)

        viewModel.trackingModel
            .asDriver()
            .drive(onNext: { [weak self] trackingModel in
                guard let state = self?.viewModel.state.value
                else { return }
                self?.infoView.configure(model: trackingModel, state: state)
            }).disposed(by: disposeBag)

        viewModel.cachedMilestones
            .bind { [weak self] milestones in
            guard let milestone = milestones.last,
                  let latitude = milestone.coordinate.latitude,
                  let longitude = milestone.coordinate.longitude
            else { return }
            self?.mapView.addAnnotation(type: .milestone,
                                        latitude,
                                        longitude)
        }.disposed(by: disposeBag)

        viewModel.saveResult
            .observe(on: MainScheduler.instance)
            .map { [weak self] value -> Bool in
                let title = value ? "저장이 완료되었습니다." : "다시 시도해주시기 바랍니다."
                self?.view.showToastView(message: title, image: .check)
                return value
            }
            .delay(.milliseconds(800), scheduler: MainScheduler.instance)
            .bind { [weak self] value in
                if value {
                    self?.navigationController?.popViewController(animated: true)
                }
                self?.infoView.rightButton.isUserInteractionEnabled = true
            }.disposed(by: disposeBag)
    }

    private func update() {
        let isStart: Bool = viewModel.state.value == .start
        infoView.update(state: viewModel.state.value)

        switch isStart {
        case true:
            manager.startUpdatingLocation()
            timerDate = Date()
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(trackingTimer),
                                         userInfo: nil,
                                         repeats: true)
        case false:
            pedomterSteps = viewModel.trackingModel.value.steps
            lastestTime = viewModel.trackingModel.value.seconds
            timer.invalidate()
            stopTracking()
        }
    }

    private func stopAnimation() {
        stopTracking()
        infoView.stopPedometerText()

        UIView.animate(withDuration: 1, animations: { [weak self] in
            guard let self = self
            else { return }
            self.infoView.stopAnimation()
            self.mapViewBottomConstraint.constant = self.view.frame.maxY - 290
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let self = self
            else { return }

            self.infoView.configureWrite()
        })
    }

    private func makeImageData() {
        guard let center = self.viewModel.centerCoordinateOfPath()
        else { return }

        let coordinates = self.viewModel.trackingModel.value.coordinates

        self.mapView.snapShotImageOfPath(backgroundColor: .clear,
                                         coordinates: coordinates,
                                         center: center,
                                         range: self.viewModel.trackingModel.value.distance) { image in
            self.viewModel.imageData.onNext(image?.pngData() ?? Data())
            self.viewModel.save()
        }
    }

    private func stopTracking() {
        manager.stopUpdatingLocation()
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }

    private func locationToAddress() -> Observable<String> {
        return Observable.create { [weak self] observable in
            guard let center = self?.viewModel.centerCoordinateOfPath()
            else { return Disposables.create { observable.onCompleted() } }

            let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let geocoder = CLGeocoder()
            let locale = Locale(identifier: "Ko-kr")
            geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { placemarks, _ in
                guard let placemarks = placemarks,
                      let address = placemarks.last
                else { return }

                observable.onNext("\(address.locality ?? "-") \(address.subLocality ?? "-"), \(address.administrativeArea ?? "")")
            }

            return Disposables.create { observable.onCompleted() }
        }
    }
    
    private func startMonitor() {
        monitor.rx
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let element = event.element,
                      let state = self?.viewModel.state.value
                else { return }
                
                switch element.status {
                case .satisfied:
                    self?.infoView.leftButton.isUserInteractionEnabled = true
                    self?.infoView.rightButton.isUserInteractionEnabled = true
                default :
                    self?.viewModel.state.accept(state == .start ? .pause : state)
                    self?.infoView.leftButton.isUserInteractionEnabled = false
                    self?.infoView.rightButton.isUserInteractionEnabled = false
                    let message = "원할한 서비스를 위해 \n네트워크를 연결해주세요\n네트워크 재연결 이후\n기록을 재시작/저장이 가능합니다."
                    self?.view.showToastView(message: message)
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: CLLocation Manager Delegate
extension TrackingProgressViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last
        else { return }

        let currentCoordinate = currentLocation.coordinate

        guard let latestCoordinate = viewModel.lastCoordinate,
              let prevLatitude = latestCoordinate.latitude,
              let prevLongitude = latestCoordinate.longitude
        else {
            let coordinate = Coordinate(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            viewModel.coordinates.onNext(Coordinates(coordinate: coordinate))
            return
        }
        let prevCoordinate = CLLocationCoordinate2D(latitude: prevLatitude, longitude: prevLongitude)
        let latestLocation = CLLocation(latitude: prevLatitude, longitude: prevLongitude)

        if viewModel.state.value == .start { mapView.drawPath(from: prevCoordinate, to: currentCoordinate) }

        viewModel.distance.onNext(latestLocation.distance(from: currentLocation))
        let coordinate = Coordinate(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        viewModel.coordinates.onNext(Coordinates(coordinate: coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            viewModel.state.accept(.pause)

            let title = "위치 권한"
            let content = "기록을 위해 위치 권한을 설정 앱에서 위치 권한을 켜주시기 바랍니다."
            let alertController: UIAlertController = .simpleAlert(title: title, message: content)

            present(alertController, animated: true)
        case .notDetermined:
            viewModel.state.accept(.pause)

            manager.requestWhenInUseAuthorization()
        default:
            if let location = manager.location, viewModel.state.value == .start {
                let coordinate = Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                viewModel.coordinates.onNext(Coordinates(coordinate: coordinate))
                mapView.setRegion(to: location, meterRadius: 100)
            }
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

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PhotoAnnotationView.identifier)
        annotationView?.canShowCallout = false
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: PhotoAnnotationView.identifier)

            guard let customView = UINib(nibName: PhotoAnnotationView.identifier, bundle: nil).instantiate(withOwner: self, options: nil).first as? PhotoAnnotationView,
                  let mileStone: Milestone = viewModel.trackingModel.value.milestones.last
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

        guard let selectedMilestone = viewModel.milestone(at: coordinate)
        else { return }

        let milestonePhotoViewModel = MilestonePhotoViewModel(milestone: selectedMilestone)
        let milestonePhotoVC = MilestonePhotoViewController(viewModel: milestonePhotoViewModel)
        milestonePhotoVC.viewModel = milestonePhotoViewModel
        milestonePhotoVC.delegate = self

        self.present(milestonePhotoVC, animated: true, completion: nil)
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
            viewModel.append(of: milestone)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: mile stone photo view controller delegate
extension TrackingProgressViewController: MilestonePhotoViewControllerDelegate {
    func delete(milestone: Milestone) {
        viewModel.remove(of: milestone)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { isRemoved in
                if isRemoved && self.mapView.removeMilestoneAnnotation(of: milestone) {
                    let title = "삭제 완료"
                    let message = "마일스톤을 삭제했어요"
                    let alertViewController: UIAlertController = .simpleAlert(title: title, message: message)
                    self.present(alertViewController, animated: true)
                }
            }).disposed(by: disposeBag)
    }
}

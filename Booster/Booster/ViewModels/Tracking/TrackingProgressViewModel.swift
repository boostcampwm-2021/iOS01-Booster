import Foundation
import CoreLocation
import RxSwift
import RxRelay

final class TrackingProgressViewModel {
    enum TrackingState {
        case start
        case pause
        case end
    }

    let title = PublishSubject<String>()
    let content = PublishSubject<String>()
    let imageData = PublishSubject<Data>()
    let seconds = PublishSubject<Int>()
    let steps = PublishSubject<Int>()
    let distance = PublishSubject<Double>()
    let saveResult = PublishSubject<Error?>()
    let coordinates = PublishSubject<Coordinates>()
    let cachedMilestones = BehaviorRelay<Milestones>(value: Milestones())
    var lastCoordinate: Coordinate? {
        return trackingModel.value.coordinates.last
    }
    private let disposeBag = DisposeBag()
    private let trackingUsecase: TrackingProgressUsecase
    private(set) var trackingModel = BehaviorRelay<TrackingModel>(value: TrackingModel())
    private(set) var userModel =  BehaviorRelay<UserInfo>(value: UserInfo())
    private(set) var state = BehaviorRelay<TrackingState>(value: .start)

    init() {
        trackingUsecase = TrackingProgressUsecase()
        fetchUserInfo()
        bind()
    }

    func save() {
        return trackingUsecase.save(model: trackingModel.value)
            .subscribe(onNext: { [weak self] in
                self?.saveResult.onNext(nil)
            }, onError: { [weak self] error in
                self?.saveResult.onNext(error)
            }).disposed(by: disposeBag)
    }

    func remove(of mileStone: Milestone) -> Observable<Bool> {
        return Observable.create { [weak self] observable in
            guard let self = self
            else { return Disposables.create() }

            if let _ = self.trackingModel.value.milestones.remove(of: mileStone) {

                observable.onNext(true)
            } else {
                observable.onNext(false)
            }

            return Disposables.create()
        }
    }

    func append(of milestone: Milestone) {
        let newMilestones = cachedMilestones.value
        newMilestones.append(milestone)
        cachedMilestones.accept(newMilestones)
    }

    func centerCoordinateOfPath() -> CLLocationCoordinate2D? {
        let center = trackingModel.value.coordinates.center()
        guard let latitude = center.latitude,
              let longitude = center.longitude
        else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func address(observable: Observable<String>) {
        observable.subscribe { [weak self] event in
            guard let element = event.element,
                  let self = self
            else { return }

            var tracking = self.trackingModel.value
            tracking.address = element

            self.trackingModel.accept(tracking)
        }.disposed(by: disposeBag)
    }

    private func bind() {
        coordinates.map { (values) -> [Coordinate] in
            let coordinates = self.trackingModel.value.coordinates
            coordinates.append(values)
            return coordinates.all
        }.bind { [weak self] values in
            guard let self = self
            else { return }

            var tracking = self.trackingModel.value
            tracking.coordinates = Coordinates(coordinates: values)
            self.trackingModel.accept(tracking)
        }.disposed(by: disposeBag)

        cachedMilestones
            .bind { [weak self] milestones in
            guard let self = self
            else { return }

            let newTrackingModel = self.trackingModel.value
            newTrackingModel.milestones.append(milestones.all)
            self.trackingModel.accept(newTrackingModel)
        }.disposed(by: disposeBag)

        state.filter {
            $0 == .end
        }.map { [weak self] (_) -> TrackingModel in
            guard let self = self
            else { return TrackingModel() }

            var tracking = self.trackingModel.value
            tracking.endDate = Date()
            self.trackingModel.accept(tracking)
            return tracking
        }.bind { [weak self] tracking in
            self?.trackingUsecase.save(count: Double(tracking.steps),
                                 start: tracking.startDate,
                                 end: tracking.endDate ?? Date(),
                                 quantity: .steps,
                                 unit: .count)
            self?.trackingUsecase.save(count: tracking.distance / 1000,
                                 start: tracking.startDate,
                                 end: tracking.endDate ?? Date(),
                                 quantity: .runing,
                                 unit: .kilometer)
            self?.trackingUsecase.save(count: Double(tracking.calories),
                                 start: tracking.startDate,
                                 end: tracking.endDate ?? Date(),
                                 quantity: .energy,
                                 unit: .calorie)
        }.disposed(by: disposeBag)

        state.filter {
            $0 == .pause
        }.bind { [weak self] _ in
            guard let self = self
            else { return }

            let tracking = self.trackingModel.value
            tracking.coordinates.append(Coordinate(latitude: nil, longitude: nil))
            self.trackingModel.accept(tracking)
        }.disposed(by: disposeBag)

        title.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.trackingModel.value
            tracking.title = value
            self.trackingModel.accept(tracking)
        }.disposed(by: disposeBag)

        content.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.trackingModel.value
            tracking.content = value
            self.trackingModel.accept(tracking)
        }.disposed(by: disposeBag)

        imageData.bind { value in
            var tracking = self.trackingModel.value
            tracking.imageData = value
            self.trackingModel.accept(tracking)
        }.disposed(by: disposeBag)

        seconds.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.trackingModel.value
            tracking.seconds = value
            self.trackingModel.accept(tracking)
        }.disposed(by: disposeBag)

        steps.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.trackingModel.value

            tracking.steps = value
            self.trackingModel.accept(tracking)
        }.disposed(by: disposeBag)

        distance.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.trackingModel.value
            let met: Double = 4.8
            let perHourDistance = 5.6 * 1000

            tracking.distance += value
            tracking.calories = Int(met * Double(self.userModel.value.weight) * (tracking.distance / perHourDistance))

            self.trackingModel.accept(tracking)
        }.disposed(by: disposeBag)
    }

    private func fetchUserInfo() {
        trackingUsecase.fetch()
            .subscribe { [weak self] value in
                self?.userModel.accept(value)
            }.disposed(by: disposeBag)
    }
}

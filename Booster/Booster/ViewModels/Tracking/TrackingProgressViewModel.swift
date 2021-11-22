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
    let coordinates = PublishSubject<[Coordinate]>()
    let addMilestones = PublishSubject<[Milestone]>()
    private let disposeBag = DisposeBag()
    private let trackingUsecase: TrackingProgressUsecase
    private(set) var tracking = BehaviorRelay<TrackingModel>(value: TrackingModel())
    private(set) var user =  BehaviorRelay<UserInfo>(value: UserInfo())
    private(set) var state = BehaviorRelay<TrackingState>(value: .start)

    init() {
        trackingUsecase = TrackingProgressUsecase()
        fetchUserInfo()
        bind()
    }

    func latestCoordinate() -> Coordinate? {
        guard let latestCoordinate = tracking.value.coordinates.last
        else { return nil }

        return latestCoordinate
    }

    func startCoordinate() -> Coordinate? {
        guard let startCoordinate = tracking.value.coordinates.first
        else { return nil }

        return startCoordinate
    }

    func save() {
        return trackingUsecase.save(model: self.tracking.value)
            .subscribe(onNext: {
                self.saveResult.onNext(nil)
            }, onError: { error in
                self.saveResult.onNext(error)
            }).disposed(by: disposeBag)
    }

    func mileStone(at coordinate: Coordinate) -> Observable<Milestone?> {
        return Observable.create { observable in
            let target = self.tracking.value.milestones.first(where: { (value) in
                return value.coordinate == coordinate
            })

            observable.onNext(target)

            return Disposables.create()
        }
    }

    func remove(of mileStone: Milestone) -> Observable<Bool> {
        return Observable.create { observable in
            var tracking = self.tracking.value

            if let index = self.tracking.value.milestones.firstIndex(of: mileStone) {
                tracking.milestones.remove(at: index)
                self.tracking.accept(tracking)

                observable.onNext(true)
            } else {
                observable.onNext(false)
            }

            return Disposables.create()
        }
    }

    func centerCoordinateOfPath() -> CLLocationCoordinate2D? {
        guard let startCoordinate = startCoordinate(),
              let startLat = startCoordinate.latitude,
              let startLong = startCoordinate.longitude
        else { return nil }

        var maxLat: Double = startLat
        var minLat: Double = startLat
        var maxLong: Double = startLong
        var minLong: Double = startLong

        tracking.value.coordinates.forEach { (coordinate) in
            guard let latValue = coordinate.latitude,
                  let longValue = coordinate.longitude
            else { return }

            if maxLat < latValue { maxLat = latValue } else if minLat > latValue { minLat = latValue }

            if maxLong < longValue { maxLong = longValue } else if minLong > longValue { minLong = longValue}
        }

        let midLat = (maxLat + minLat) / 2.0
        let midLong = (maxLong + minLong) / 2.0

        return CLLocationCoordinate2D(latitude: midLat, longitude: midLong)
    }

    private func bind() {
        coordinates.map { (values) -> [Coordinate] in
            var coordinates = self.tracking.value.coordinates
            coordinates += values
            return coordinates
        }.bind { [weak self] values in
            guard let self = self
            else { return }

            var tracking = self.tracking.value
            tracking.coordinates = values
            self.tracking.accept(tracking)
        }.disposed(by: disposeBag)

        addMilestones.map { (values) -> [Milestone] in
            var milestones = self.tracking.value.milestones
            milestones += values
            return milestones
        }.bind { [weak self] values in
            guard let self = self
            else { return }

            var tracking = self.tracking.value
            tracking.milestones = values
            self.tracking.accept(tracking)
        }.disposed(by: disposeBag)

        state.filter {
            $0 == .end
        }.map { [weak self] (_) -> TrackingModel in
            guard let self = self
            else { return TrackingModel() }

            var tracking = self.tracking.value
            tracking.endDate = Date()
            self.tracking.accept(tracking)
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

        title.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.tracking.value
            tracking.title = value
            self.tracking.accept(tracking)
        }.disposed(by: disposeBag)

        content.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.tracking.value
            tracking.content = value
            self.tracking.accept(tracking)
        }.disposed(by: disposeBag)

        imageData.bind { value in
            var tracking = self.tracking.value
            tracking.imageData = value
            self.tracking.accept(tracking)
        }.disposed(by: disposeBag)

        seconds.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.tracking.value
            tracking.seconds = value
            self.tracking.accept(tracking)
        }.disposed(by: disposeBag)

        steps.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.tracking.value

            tracking.steps = value
            self.tracking.accept(tracking)
        }.disposed(by: disposeBag)

        distance.bind { [weak self] value in
            guard let self = self
            else { return }

            var tracking = self.tracking.value
            let met: Double = 4.8
            let perHourDistance = 5.6 * 1000

            tracking.distance += value
            tracking.calories = Int(met * Double(self.user.value.weight) * (tracking.distance / perHourDistance))

            self.tracking.accept(tracking)
        }.disposed(by: disposeBag)
    }

    private func fetchUserInfo() {
        trackingUsecase.fetch()
            .subscribe { [weak self] value in
                self?.user.accept(value)
            }.disposed(by: disposeBag)
    }
}

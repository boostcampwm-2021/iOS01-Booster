//
//  DetailFeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/08.
//

import Foundation
import RxSwift
import RxRelay

final class DetailFeedViewModel {
    // MARK: - Properties
    let startDate: Date
    var trackingModel = BehaviorRelay<TrackingModel>(value: TrackingModel())
    var isDeletedMilestone = PublishSubject<Bool>()
    var isDeletedAll = PublishSubject<Bool>()
    private let predicate: NSPredicate
    private let usecase = DetailFeedUsecase()
    private let disposeBag = DisposeBag()
    private var gradientColorOffset = -1

    // MARK: - Init
    init(start date: Date) {
        startDate = date
        predicate = NSPredicate(format: "startDate = %@", startDate as NSDate)
        fetchDetailFeedList()
    }

    // MARK: - Functions
    func milestone(at coordinate: Coordinate) -> Milestone? {
        return trackingModel.value.milestones.milestone(at: coordinate)
    }

    func reset() { gradientColorOffset = -1 }

    func remove(of milestone: Milestone) {
        let newTrackingModel = self.trackingModel.value
        _ = newTrackingModel.milestones.remove(of: milestone)

        usecase.update(milestones: newTrackingModel.milestones.all, predicate: predicate)
            .subscribe(onError: { _ in
                self.isDeletedMilestone.onNext(false)
            }, onCompleted: {
                self.trackingModel.accept(newTrackingModel)
                self.isDeletedMilestone.onNext(true)
            })
            .disposed(by: disposeBag)
    }

    func removeAll() {
        usecase.remove(predicate: predicate)
            .subscribe(onError: { _ in
                self.isDeletedAll.onNext(false)
            }, onCompleted: {
                self.isDeletedAll.onNext(true)
            })
            .disposed(by: disposeBag)
    }

    func offsetOfGradientColorCoordinate() -> Coordinate? {
        gradientColorOffset += 1
        return trackingModel.value.coordinates[gradientColorOffset] ?? nil
    }

    func indexRatioOfCoordinate(_ coordinate: Coordinate) -> Double? {
        return trackingModel.value.coordinates.indexRatio(coordinate)
    }

    func fetchDetailFeedList() {
        usecase.fetch(predicate: predicate)
            .subscribe { [weak self] value in
                guard let model = value.element
                else { return }

                self?.trackingModel.accept(model)
            }
            .disposed(by: disposeBag)
    }

    func createModifyFeedViewModel() -> ModifyFeedViewModel {
        let writingRecord = WritingRecord(title: trackingModel.value.title, content: trackingModel.value.content)
        return ModifyFeedViewModel(startDate: startDate, writingRecord: writingRecord)
    }
}

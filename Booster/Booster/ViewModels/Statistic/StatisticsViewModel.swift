//
//  StatisticsViewModel.swift
//  Booster
//
//  Created by Hani on 2021/11/16.
//

import Foundation

import RxCocoa
import RxSwift

final class StatisticsViewModel {
    // MARK: - Enums
    enum Duration: Int {
        case week, month, year
    }

    // MARK: - Properties
    private let usecase = StatisticsUsecase()
    private let disposeBag = DisposeBag()

    private var weekStepStatisticsCollection: StepStatisticsCollection?
    private var monthStepStatisticsCollection: StepStatisticsCollection?
    private var yearStepStatisticsCollection: StepStatisticsCollection?

    var selectedDuration: BehaviorRelay<Duration> = BehaviorRelay(value: .week)
    var selectedStatisticsIndex: BehaviorRelay<Int?> = BehaviorRelay(value: nil)

    // MARK: - init
    init() {
        bind()
    }

    // MARK: - functions
    func selectedStatisticsCollection() -> StepStatisticsCollection? {
        switch selectedDuration.value {
        case .week : return weekStepStatisticsCollection
        case .month: return monthStepStatisticsCollection
        case .year : return yearStepStatisticsCollection
        }
    }

    func bind() {
        selectedDuration
            .subscribe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .bind { [weak self] _ in
              self?.selectedStatisticsIndex.accept(nil)
            }
            .disposed(by: disposeBag)
    }

    func selectStatistics(tappedCoordinate: Float) {
        guard let statisticsCollection = selectedStatisticsCollection(),
              statisticsCollection.count > 0
        else { return }

        let offset = 1 / Float(statisticsCollection.count)
        let selectedIndex = Int(tappedCoordinate / offset)

        if selectedStatisticsIndex.value != selectedIndex {
            selectedStatisticsIndex.accept(selectedIndex)
        } else {
            selectedStatisticsIndex.accept(nil)
        }
    }

    func selectStatistics(pannedCoordinate: Float) {
        guard let statisticsCollection = selectedStatisticsCollection(),
              statisticsCollection.count > 0
        else { return }

        let offset = 1 / Float(statisticsCollection.count)
        let selectedIndex = Int(pannedCoordinate / offset)

        if selectedStatisticsIndex.value != selectedIndex {
            selectedStatisticsIndex.accept(selectedIndex)
        }
    }

    func requestQueryForStatisticsCollection() {
        usecase.execute(duration: .weekOfMonth, interval: .init(day: 1))
            .subscribe { [weak self] stepStatisticsCollection in
                if case let .success(stepStatisticsCollection) = stepStatisticsCollection {
                    self?.weekStepStatisticsCollection = stepStatisticsCollection
                }
            }.disposed(by: disposeBag)

        usecase.execute(duration: .month, interval: .init(weekOfMonth: 1))
            .subscribe { [weak self] stepStatisticsCollection in
                if case let .success(stepStatisticsCollection) = stepStatisticsCollection {
                    self?.monthStepStatisticsCollection = stepStatisticsCollection
                }
            }.disposed(by: disposeBag)

        usecase.execute(duration: .year, interval: .init(month: 1))
            .subscribe { [weak self] stepStatisticsCollection in
                if case let .success(stepStatisticsCollection) = stepStatisticsCollection {
                    self?.yearStepStatisticsCollection = stepStatisticsCollection
                }
            }.disposed(by: disposeBag)
    }

}

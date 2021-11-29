//
//  StatisticsViewController.swift
//  Booster
//
//  Created by Hani on 2021/11/17.
//

import HealthKit
import UIKit

import RxGesture
import RxSwift

final class StatisticsViewController: UIViewController, BaseViewControllerTemplate {
    typealias Duration = StatisticsViewModel.Duration

    // MARK: - @IBOutlet
    @IBOutlet private weak var weekButton: UIButton!
    @IBOutlet private weak var monthButton: UIButton!
    @IBOutlet private weak var yearButton: UIButton!

    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var averageStepCountLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    @IBOutlet private weak var chartView: SelectionChartView!

    // MARK: - Properties
    private let disposeBag = DisposeBag()

    var viewModel = StatisticsViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        addGestures()
        addActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        requestAuthorizationForStepCount()
    }

    // MARK: - functions
    private func requestAuthorizationForStepCount() {
        guard let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)
        else { return }

        HealthKitManager.shared.requestAuthorization(shareTypes: [stepCount], readTypes: [stepCount])
            .subscribe { [weak self] requestResult in
                if case .success = requestResult {
                    self?.viewModel.requestQueryForStatisticsCollection()
                }
            }.disposed(by: disposeBag)
    }

    private func addGestures() {
        chartView.rx
            .tapGesture()
            .when(.recognized)
            .asLocation(in: .view)
            .bind(onNext: { [weak self] location in
                guard let self = self,
                      (0..<self.chartView.frame.width).contains(location.x)
                else { return }

                self.viewModel.selectStatistics(tappedCoordinate: Float(location.x / self.chartView.frame.width))
            })
            .disposed(by: disposeBag)

        chartView.rx
            .panGesture()
            .when(.changed)
            .asLocation(in: .view)
            .bind(onNext: { [weak self] location in
                guard let self = self,
                      (0..<self.chartView.frame.width).contains(location.x)
                else { return }

                self.viewModel.selectStatistics(pannedCoordinate: Float(location.x / self.chartView.frame.width))
            })
            .disposed(by: disposeBag)
    }

    private func addActions() {
        weekButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self
                else { return }

                self.weekButton.tintColor  = .boosterLabel
                self.monthButton.tintColor = .boosterGray
                self.yearButton.tintColor  = .boosterGray
                self.durationLabel.text = "하루 평균"
                self.viewModel.selectedDuration.accept(.week)
            })
            .disposed(by: disposeBag)

        monthButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self
                else { return }

                self.weekButton.tintColor  = .boosterGray
                self.monthButton.tintColor = .boosterLabel
                self.yearButton.tintColor  = .boosterGray
                self.durationLabel.text = "한주 평균"
                self.viewModel.selectedDuration.accept(.month)
            })
            .disposed(by: disposeBag)

        yearButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self
                else { return }

                self.weekButton.tintColor  = .boosterGray
                self.monthButton.tintColor = .boosterGray
                self.yearButton.tintColor  = .boosterLabel
                self.durationLabel.text = "한달 평균"
                self.viewModel.selectedDuration.accept(.year)
            })
            .disposed(by: disposeBag)
    }

    private func bind() {
        viewModel.selectedDuration
            .subscribe(on: MainScheduler.instance)
            .debounce(RxTimeInterval.milliseconds(50), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(onNext: { [weak self] _ in
                guard let self = self,
                      let statisticsCollection = self.viewModel.selectedStatisticsCollection()
                else { return }

                self.updateDuration(using: statisticsCollection)
            })
            .disposed(by: disposeBag)

        viewModel.selectedStatisticsIndex
            .subscribe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(onNext: { [weak self] index in
                guard let self = self,
                      let statisticsCollection = self.viewModel.selectedStatisticsCollection()
                else { return }

                self.updateSelection(using: statisticsCollection, index: index)
            })
            .disposed(by: disposeBag)
    }

    private func updateDuration(using statisticsCollection: StepStatisticsCollection) {
        guard let stepCount = statisticsCollection.stepCountPerDuration()
        else { return }

        averageStepCountLabel.text = String(stepCount)
        dateLabel.text = statisticsCollection.durationString

        let strings = statisticsCollection.abbreviatedStrings()
        let stepRatios = statisticsCollection.stepRatios().map { CGFloat($0) }
        chartView.drawChart(stepRatios: stepRatios, strings: strings)
    }

    private func updateSelection(using statisticsCollection: StepStatisticsCollection, index: Int?) {
        guard let index = index
        else {
            chartView.clearSelection()
            return
        }

        let xOffset = 1 / CGFloat(statisticsCollection.count)
        let centerLabel = 0.5
        let xCoordinate = (centerLabel + CGFloat(index)) * xOffset * chartView.frame.width
        let stepRatios = statisticsCollection.stepRatios()
        let height = 1 - CGFloat(stepRatios[index])

        let selectedStatistics: StepStatistics = statisticsCollection[index]
        let step = selectedStatistics.step
        let interval = selectedStatistics.intervalString

        chartView.updateSelection(interval: interval, step: step, x: xCoordinate, height: height)
    }
}

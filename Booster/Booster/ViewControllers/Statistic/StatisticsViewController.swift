//
//  aaVC.swift
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

    @IBOutlet private weak var chartView: ChartView!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let sideInset: CGFloat = 20
    private let fontSize: CGFloat = 15
    private lazy var barView: UIView = {
        let view = UIView()
        view.backgroundColor = .boosterLabel
        return view
    }()

    private lazy var intervalLabel: UILabel = {
        let label = UILabel()
        label.frame.origin.y = chartView.frame.origin.y
        label.font = UIFont.bazaronite(size: fontSize)
        label.textColor = UIColor.boosterLabel
        return label
    }()

    private lazy var stepCountLabel: UILabel = {
        let label = UILabel()
        label.frame.origin.y = chartView.frame.origin.y + fontSize
        label.font = UIFont.bazaronite(size: fontSize)
        label.textColor = UIColor.boosterLabel
        return label
    }()

    var viewModel = StatisticsViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        requestAuthorizationForStepCount()
        addGestures()
        addActions()
    }

    // MARK: - functions
    private func addSubviews() {
        view.addSubview(intervalLabel)
        view.addSubview(stepCountLabel)
        view.addSubview(barView)
    }

    private func requestAuthorizationForStepCount() {
        guard let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)
        else { return }

        HealthStoreManager.shared.requestAuthorization(shareTypes: [stepCount], readTypes: [stepCount]) { [weak self] success in
            if success {
                self?.viewModel.requestQueryForStatisticsCollection()
            }
        }
    }

    private func addGestures() {
        chartView.rx
            .tapGesture()
            .when(.recognized)
            .asLocation(in: .view)
            .subscribe(onNext: { [weak self] location in
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
            .subscribe(onNext: { [weak self] location in
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
            .debounce(RxTimeInterval.milliseconds(50), scheduler: MainScheduler.instance)
            .subscribe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let self = self,
                      let statisticsCollection = self.viewModel.selectedStatisticsCollection(),
                      let stepRatios = statisticsCollection.stepRatios()?.map({ CGFloat($0) }),
                      let stepCount = statisticsCollection.stepCountPerDuration()
                else { return }

                let strings = statisticsCollection.abbreviatedStrings()
                self.chartView.drawChart(stepRatios: stepRatios, strings: strings)
                self.averageStepCountLabel.text = String(stepCount)
                self.dateLabel.text = statisticsCollection.durationString
            })
            .disposed(by: disposeBag)

        viewModel.selectedStatisticsIndex
            .subscribe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] index in
                guard let self = self,
                      let statisticsCollection = self.viewModel.selectedStatisticsCollection()
                else { return }

                self.updateSelectedLabel(using: statisticsCollection, index: index)
            })
            .disposed(by: disposeBag)
    }

    private func updateSelectedLabel(using statisticsCollection: StepStatisticsCollection, index: Int?) {
        guard let index = index,
              let stepRatios = statisticsCollection.stepRatios()
        else {
            stepCountLabel.text = String()
            intervalLabel.text = String()
            barView.frame = .zero
            return
        }

        let selectedStatistics: StepStatistics = statisticsCollection[index]

        let step = selectedStatistics.step
        let intervalString = selectedStatistics.intervalString

        let xOffset = 1 / CGFloat(statisticsCollection.count)
        let centerLabel = 0.5
        let xCoordinate = (centerLabel + CGFloat(index)) * xOffset * chartView.frame.width + sideInset
        let stepRatio = 1 - CGFloat(stepRatios[index])

        intervalLabel.text = intervalString
        intervalLabel.sizeToFit()
        intervalLabel.center.x = xCoordinate

        intervalLabel.frame.origin.x = max(intervalLabel.frame.origin.x, sideInset)
        intervalLabel.frame.origin.x = min(intervalLabel.frame.origin.x, view.frame.width - intervalLabel.frame.width - sideInset)

        stepCountLabel.text = "\(step)걸음"
        stepCountLabel.sizeToFit()
        stepCountLabel.center.x = xCoordinate

        stepCountLabel.frame.origin.x = max(stepCountLabel.frame.origin.x, sideInset)
        stepCountLabel.frame.origin.x = min(stepCountLabel.frame.origin.x, view.frame.width - stepCountLabel.frame.width - sideInset)

        barView.frame = CGRect(x: xCoordinate,
                               y: chartView.frame.origin.y + fontSize * 2,
                               width: 1,
                               height: chartView.topSpace - fontSize * 2 + chartView.centerSpace * stepRatio)
    }
}

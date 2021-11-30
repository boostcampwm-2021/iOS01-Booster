//
//  StepStatisticsTests.swift
//  StatisticsTests
//
//  Created by Hani on 2021/11/22.
//

import XCTest

final class StepStatisticsTests: XCTestCase {
    private var stepStatisticsCollection: StepStatisticsCollection!

    override func setUpWithError() throws {
        stepStatisticsCollection = StepStatisticsCollection()
    }

    override func tearDownWithError() throws {
        stepStatisticsCollection = nil
    }

    func test_통계추가_성공() throws {
        // given
        let stepStatistics = StepStatistics(step: 1, intervalString: String(), abbreviatedDateString: String())

        // when
        stepStatisticsCollection.append(statistics: statistics)
        let resultStepStatistics: StepStatistics = stepStatisticsCollection[0]

        // then
        XCTAssertEqual(statistics, resultStatistics)
    }

    func test_통계하나이상있을때_최대값통계_리턴_성공() throws {
        // given
        let stepFourStatistics = StepStatistics(step: 4, intervalString: String(), abbreviatedDateString: String())
        let stepSixStatistics = StepStatistics(step: 6, intervalString: String(), abbreviatedDateString: String())
        let stepFiveStatistics = StepStatistics(step: 5, intervalString: String(), abbreviatedDateString: String())
        stepStatisticsCollection.append(statistics: stepFourStatistics)
        stepStatisticsCollection.append(statistics: stepSixStatistics)
        stepStatisticsCollection.append(statistics: stepFiveStatistics)

        // when
        let resultStatistics: StepStatistics? = stepStatisticsCollection.maxStepStatistics()

        // then
        XCTAssertEqual(stepSixStatistics, resultStatistics)
    }

    func test_통계하나도없을때_최대값통계_리턴_실패() throws {
        // given

        // when
        let resultStepStatistics: StepStatistics? = stepStatisticsCollection.maxStepStatistics()

        // then
        XCTAssertNil(resultStepStatistics)
    }

    func test_통계하나이상있을때_평균걸음수_리턴_성공() throws {
        // given
        let stepFourStatistics = StepStatistics(step: 4, intervalString: String(), abbreviatedDateString: String())
        let stepSixStatistics = StepStatistics(step: 6, intervalString: String(), abbreviatedDateString: String())
        let stepFiveStatistics = StepStatistics(step: 5, intervalString: String(), abbreviatedDateString: String())
        stepStatisticsCollection.append(statistics: stepFourStatistics)
        stepStatisticsCollection.append(statistics: stepSixStatistics)
        stepStatisticsCollection.append(statistics: stepFiveStatistics)

        // when
        let stepCountPerDuration: Int? = stepStatisticsCollection.stepCountPerDuration()

        // then
        XCTAssertEqual(stepCountPerDuration, 5)
    }

    func test_통계하나도없을때_평균걸음수_리턴_실패() throws {
        // given

        // when
        let stepCountPerDuration: Int? = stepStatisticsCollection.stepCountPerDuration()

        // then
        XCTAssertNil(stepCountPerDuration)
    }

    func test_통계하나이상있을때_걸음비율_리턴_성공() throws {
        // given
        let stepFourStatistics = StepStatistics(step: 2, intervalString: String(), abbreviatedDateString: String())
        let stepSixStatistics = StepStatistics(step: 4, intervalString: String(), abbreviatedDateString: String())
        let stepFiveStatistics = StepStatistics(step: 8, intervalString: String(), abbreviatedDateString: String())
        stepStatisticsCollection.append(statistics: stepFourStatistics)
        stepStatisticsCollection.append(statistics: stepSixStatistics)
        stepStatisticsCollection.append(statistics: stepFiveStatistics)

        // when
        let stepRatios: [Float]? = stepStatisticsCollection.stepRatios()

        // then
        XCTAssertEqual(stepRatios, [0.25, 0.5, 1.0])
    }

    func test_통계하나도없을때_걸음비율_리턴_실패() throws {
        // given

        // when
        let stepRatios: [Float]? = stepStatisticsCollection.stepRatios()

        // then
        XCTAssertNil(stepRatios)
    }
}

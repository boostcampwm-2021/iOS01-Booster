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
        let stepStatistics = StepStatistics(step: 1, abbreviatedDateString: String(), intervalString: String())

        // when
        stepStatisticsCollection.append(stepStatistics)
        let resultStepStatistics: StepStatistics = stepStatisticsCollection[0]

        // then
        XCTAssertEqual(stepStatistics, resultStepStatistics)
    }

    func test_통계하나이상있을때_평균걸음수_리턴_성공() throws {
        // given
        let stepFourStatistics = StepStatistics(step: 4, abbreviatedDateString: String(), intervalString: String())
        let stepSixStatistics = StepStatistics(step: 6, abbreviatedDateString: String(), intervalString: String())
        let stepFiveStatistics = StepStatistics(step: 5, abbreviatedDateString: String(), intervalString: String())
        stepStatisticsCollection.append(stepFourStatistics)
        stepStatisticsCollection.append(stepSixStatistics)
        stepStatisticsCollection.append(stepFiveStatistics)

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
        let stepFourStatistics = StepStatistics(step: 2, abbreviatedDateString: String(), intervalString: String())
        let stepSixStatistics = StepStatistics(step: 4, abbreviatedDateString: String(), intervalString: String())
        let stepFiveStatistics = StepStatistics(step: 8, abbreviatedDateString: String(), intervalString: String())
        stepStatisticsCollection.append(stepFourStatistics)
        stepStatisticsCollection.append(stepSixStatistics)
        stepStatisticsCollection.append(stepFiveStatistics)

        // when
        let stepRatios: [Float]? = stepStatisticsCollection.stepRatios()

        // then
        XCTAssertEqual(stepRatios, [0.25, 0.5, 1.0])
    }

    func test_통계하나도없을때_걸음비율_리턴_실패() throws {
        // given

        // when
        let stepRatios: [Float] = stepStatisticsCollection.stepRatios()

        // then
        XCTAssertTrue(stepRatios.isEmpty)
    }
}

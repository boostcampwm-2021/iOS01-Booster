//
//  StatisticsTests.swift
//  StatisticsTests
//
//  Created by Hani on 2021/11/11.
//

import XCTest

final class StatisticsModelTests: XCTestCase {

    var statisticsCollection: StatisticsCollection!

    override func setUpWithError() throws {
        statisticsCollection = StatisticsCollection()
    }

    override func tearDownWithError() throws {
        statisticsCollection = nil
    }

    func test_통계추가_성공() throws {
        // given
        let statistics = Statistics(date: Date(), step: Int())

        // when
        statisticsCollection.append(statistics: statistics)
        let resultStatistics: Statistics = statisticsCollection[0]

        // then
        XCTAssertEqual(statistics, resultStatistics)
    }

    func test_통계배열리턴_성공() throws {
        // given
        let statistics = Statistics(date: Date(), step: Int())
        var statisticsArray = [Statistics]()
        statisticsArray.append(statistics)

        // when
        statisticsCollection.append(statistics: statistics)
        let resultStatisticsArray: [Statistics] = statisticsCollection.statistics()

        // then
        XCTAssertEqual(statisticsArray, resultStatisticsArray)
    }

    func test_통계비교_성공() throws {
        // given
        let stepFiveStatistics = Statistics(date: Date(), step: 5)
        let stepFourStatistics = Statistics(date: Date(), step: 4)

        // when
        let resultBooleanValue: Bool = stepFourStatistics < stepFiveStatistics

        // then
        XCTAssertTrue(resultBooleanValue)
    }

    func test_통계하나이상있을때_최대값통계_리턴_성공() throws {
        // given
        let stepFourStatistics = Statistics(date: Date(), step: 4)
        let stepSixStatistics = Statistics(date: Date(), step: 6)
        let stepFiveStatistics = Statistics(date: Date(), step: 5)
        statisticsCollection.append(statistics: stepFourStatistics)
        statisticsCollection.append(statistics: stepSixStatistics)
        statisticsCollection.append(statistics: stepFiveStatistics)

        // when
        let resultStatistics: Statistics? = statisticsCollection.maxStatistics()

        // then
        XCTAssertEqual(stepSixStatistics, resultStatistics)
    }

    func test_통계하나도없을때_최대값통계_리턴_실패() throws {
        // given

        // when
        let resultStatistics: Statistics? = statisticsCollection.maxStatistics()

        // then
        XCTAssertNil(resultStatistics)
    }

    func test_통계평균값정수_리턴_성공() throws {
        // given
        let stepFourStatistics = Statistics(date: Date(), step: 4)
        let stepSixStatistics = Statistics(date: Date(), step: 6)
        let stepFiveStatistics = Statistics(date: Date(), step: 5)
        statisticsCollection.append(statistics: stepFourStatistics)
        statisticsCollection.append(statistics: stepSixStatistics)
        statisticsCollection.append(statistics: stepFiveStatistics)
        let averageStep: Int = (stepFourStatistics.step + stepFiveStatistics.step + stepSixStatistics.step) / statisticsCollection.count

        // when
        let resultAverageStep: Int = statisticsCollection.averageStatistics()

        // then
        XCTAssertEqual(averageStep, resultAverageStep)
    }
}

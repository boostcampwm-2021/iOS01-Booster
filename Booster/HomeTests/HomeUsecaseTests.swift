//
//  HomeUsecaseTests.swift
//  HomeTests
//
//  Created by Hani on 2021/11/30.
//

import XCTest

import RxCocoa
import RxSwift

final class HomeUsecaseTests: XCTestCase {
    private var usecase: HomeUsecase!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        usecase = HomeUsecase()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        usecase = nil
        disposeBag = nil
    }

    func test_헬스킷_오늘_시간당걸음수_쿼리요청_성공() throws {
        // given
        let expectation = expectation(description: "Query")
        
        // when
        usecase.fetchHourlyStepCountsData()
            .subscribe({ queryResult in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // then
        waitForExpectations(timeout: 2)
    }
    
    func test_헬스킷_오늘_총데이터_쿼리요청_성공() throws {
        // given
        let expectation = expectation(description: "Query")
        
        // when
        usecase.fetchTodayTotalData(type: .distanceWalkingRunning)
            .subscribe({ queryResult in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // then
        waitForExpectations(timeout: 2)
    }
    
    func test_코어데이터_걸음수목표_쿼리요청_성공() throws {
        // given
        let expectation = expectation(description: "Query")
        
        // when
        usecase.fetchGoalData()
            .subscribe({ queryResult in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // then
        waitForExpectations(timeout: 2)
    }
}

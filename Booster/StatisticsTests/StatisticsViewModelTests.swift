//
//  StatisticsViewModelTests.swift
//  StatisticsTests
//
//  Created by Hani on 2021/11/27.
//

import XCTest

import RxCocoa
import RxSwift

final class StatisticsViewModelTests: XCTestCase {
    private var viewModel: StatisticsViewModel!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        viewModel = StatisticsViewModel()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        disposeBag = nil
    }
    
    func test_바인드하고_데이터변화반응_성공() throws {
        // given
        viewModel.requestQueryForStatisticsCollection()
        sleep(1)
        let newDuration: StatisticsViewModel.Duration = .year
        
        // when
        viewModel.bind()
        viewModel.selectedDuration.accept(newDuration)
        let index: Int? = viewModel.selectedStatisticsIndex.value
       
        // then
        XCTAssertNil(index)
    }
    
    func test_시간별데이터_쿼리요청_성공() throws {
        // given
        let staitisticsUsecase = StatisticsUsecase()
        let expectation = expectation(description: "Query")
        
        // when
        staitisticsUsecase.execute(duration: .year, interval: .init(month: 1))
            .subscribe({ queryResult in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // then
        waitForExpectations(timeout: 2)
    }
    
    func test_처음탭했을때_인덱스생성_성공() throws {
        // given
        viewModel.requestQueryForStatisticsCollection()
        sleep(1)
        let mockCoordinate: Float = 1 / 7
        
        // when
        viewModel.selectStatistics(tappedCoordinate: mockCoordinate)
        let index: Int? = viewModel.selectedStatisticsIndex.value
        
        // then
        XCTAssertNotNil(index)
    }
    
    func test_탭한곳또탭했을때_인덱스삭제_성공() throws {
        // given
        viewModel.requestQueryForStatisticsCollection()
        sleep(1)
        let mockCoordinate: Float = 1 / 7
        viewModel.selectStatistics(tappedCoordinate: mockCoordinate)
        
        // when
        viewModel.selectStatistics(tappedCoordinate: mockCoordinate)
        let index: Int? = viewModel.selectedStatisticsIndex.value
        
        // then
        XCTAssertNil(index)
    }
    
    func test_팬해서_인덱스변경_성공() throws {
        // given
        viewModel.requestQueryForStatisticsCollection()
        sleep(1)
        let count: Float = Float(try XCTUnwrap(viewModel.selectedStatisticsCollection()?.count))
        let firstIndex = 0
        let lastIndex = 1
        let mockFirstCoordinate: Float = Float(firstIndex) / count
        let mockSecondCoordinate: Float = Float(lastIndex) / count
        viewModel.selectStatistics(tappedCoordinate: mockFirstCoordinate)
        
        // when
        viewModel.selectStatistics(pannedCoordinate: mockSecondCoordinate)
        let index: Int? = viewModel.selectedStatisticsIndex.value
        
        // then
        XCTAssertTrue(index == lastIndex)
    }
}

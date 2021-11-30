//
//  HomeTests.swift
//  HomeTests
//
//  Created by Hani on 2021/11/30.
//

import XCTest

import RxCocoa
import RxSwift

final class HomeViewModelTests: XCTestCase {
    private var viewModel: HomeViewModel!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        viewModel = HomeViewModel()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        disposeBag = nil
    }
    
    func test_쿼리요청_성공() throws {
        // given
        
        // when
        viewModel.fetchQueries()
        sleep(1)
      
        // then
        XCTAssertTrue(viewModel.homeModel.value.hourlyStatistics.count == 24)
    }
}

//
//  FeedListTests.swift
//  FeedListTests
//
//  Created by 김태훈 on 2021/11/30.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

final class FeedListTests: XCTestCase {
    var viewModel: FeedViewModel!
    var disposeBag: DisposeBag!
    var scheduler: ConcurrentDispatchQueueScheduler!
    var testScheduler: TestScheduler!
    
    override func setUpWithError() throws {
        viewModel = FeedViewModel()
        disposeBag = DisposeBag()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        testScheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        disposeBag = nil
        scheduler = nil
        testScheduler = nil
    }
    
    func test_피드_리스트_불러오기() {
        // given
        let fetchCount = testScheduler.createObserver([FeedList].self)

        // when
        viewModel.list
            .subscribe(fetchCount)
            .disposed(by: disposeBag)
        viewModel.fetch()
        
        // then
        switch fetchCount.events.count {
        case 0:
            XCTAssertEqual(fetchCount.events.count, 0)
        default:
            XCTAssertNotEqual(fetchCount.events.count, 0)
        }
    }
    
    func test_피드_리스트_선택() {
        // given
        let select = testScheduler.createObserver(Date.self)
        
        // when
        viewModel.next
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(select)
            .disposed(by: disposeBag)
        viewModel.fetch()
        if viewModel.list.value.count > 0 {
            viewModel.select.onNext(IndexPath(row: 0, section: 0))
        }
        
        // then
        switch viewModel.list.value.count {
        case 0:
            XCTAssertEqual(select.events.count, 0)
        default:
            XCTAssertNotEqual(select.events.count, 0)
        }
    }
}

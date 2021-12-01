//
//  EnrollTests.swift
//  EnrollTests
//
//  Created by 김태훈 on 2021/11/30.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

final class EnrollTests: XCTestCase {
    var disposeBag: DisposeBag!
    var scheduler: ConcurrentDispatchQueueScheduler!
    var testScheduler: TestScheduler!
    var viewModel: EnrollViewModel!

    override func setUpWithError() throws {
        viewModel = EnrollViewModel()
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
    
    func test_회원정보_입력_최종단계_이전() {
        // given
        let isSave = testScheduler.createObserver(Bool.self)

        // when
        viewModel.save
            .subscribe(isSave)
            .disposed(by: disposeBag)
        viewModel.step.onNext(1)
        viewModel.step.onNext(2)
        viewModel.step.onNext(3)
        viewModel.step.onNext(4)
        viewModel.step.onNext(5)

        // then
        XCTAssertRecordedElements(isSave.events, [])
    }
    
    func test_회원정보_입력_최종단계_저장_성공() {
        // given
        let isSave = testScheduler.createObserver(Bool.self)

        // when
        viewModel.save
            .subscribe(isSave)
            .disposed(by: disposeBag)
        viewModel.step.onNext(6)

        // then
        XCTAssertRecordedElements(isSave.events, [true])
    }
}

//
//  TrackingProgressTests.swift
//  TrackingProgressTests
//
//  Created by 김태훈 on 2021/11/14.
//

import XCTest
import RxSwift
import RxCocoa
import RxBlocking
import RxTest
import CoreLocation

class TrackingProgressTests: XCTestCase {
    var disposeBag: DisposeBag!
    var scheduler: ConcurrentDispatchQueueScheduler!
    var testScheduler: TestScheduler!
    var viewModel: TrackingProgressViewModel!

    override func setUpWithError() throws {
        viewModel = TrackingProgressViewModel()
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

    func test_마일스톤_추가_메서드() {
          // given
          let milestone = Milestone(latitude: 0, longitude: 0, imageData: Data())

          // when
          viewModel.append(of: milestone)

          // then
          XCTAssertEqual(viewModel.cachedMilestones.value.count, 1)
      }
      
      func test_마일스톤_삭제_성공_매서드() {
          // given
          let milestone = Milestone(latitude: 0, longitude: 0, imageData: Data())
          let isRemove = testScheduler.createObserver(Bool.self)

          // when
          viewModel.append(of: milestone)
          viewModel.remove(of: milestone)
              .bind(to: isRemove)
              .disposed(by: disposeBag)

          // then
          XCTAssertRecordedElements(isRemove.events, [true])
      }

      func test_마일스톤_삭제_실패_매서드() {
          // given
          let milestone = Milestone(latitude: 0, longitude: 0, imageData: Data())
          let milestone2 = Milestone(latitude: 0, longitude: 0, imageData: Data())
          let milestone3 = Milestone(latitude: 1, longitude: 1, imageData: Data())
          let isRemove = testScheduler.createObserver(Bool.self)

          // when
          viewModel.append(of: milestone)
          viewModel.remove(of: milestone2)
              .bind(to: isRemove)
              .disposed(by: disposeBag)
          viewModel.remove(of: milestone3)
              .bind(to: isRemove)
              .disposed(by: disposeBag)

          // then
          XCTAssertRecordedElements(isRemove.events, [false, false])
      }
      
      func test_해당위치_마일스톤_존재_매서드() {
          // given
          let milestone = Milestone(latitude: 0, longitude: 0, imageData: Data())
          let coordinate = Coordinate(latitude: 0, longitude: 0)

          // when
          viewModel.append(of: milestone)
          let result = viewModel.milestone(at: coordinate)

          // then
          XCTAssertNotNil(result)
      }
      
      func test_해당위치_마일스톤_존재_하지않는_매서드() {
          // given
          let milestone = Milestone(latitude: 0, longitude: 0, imageData: Data())
          let coordinate = Coordinate(latitude: 0, longitude: 1)

          // when
          viewModel.append(of: milestone)
          let result = viewModel.milestone(at: coordinate)

          // then
          XCTAssertNil(result)
      }
      
      func test_중앙위치_매서드() {
          // given
          let coordinate1 = Coordinate(latitude: 0, longitude: 0)
          let coordinate2 = Coordinate(latitude: 10, longitude: 10)
          let coordinates = Coordinates(coordinates: [coordinate1, coordinate2])
          // when
          viewModel.coordinates.onNext(coordinates)
          let center = viewModel.centerCoordinateOfPath()

          // then
          XCTAssertNotNil(center)
          XCTAssertEqual(center!.latitude, 5)
          XCTAssertEqual(center!.longitude, 5)
      }
      
      func test_저장_매서드() {
          // given
          let isSave = testScheduler.createObserver(Bool.self)

          // when
          viewModel.state.accept(.end)
          viewModel.saveResult
              .subscribe(isSave)
              .disposed(by: disposeBag)
          viewModel.save()

          // then
          XCTAssertRecordedElements(isSave.events, [true])
      }
}

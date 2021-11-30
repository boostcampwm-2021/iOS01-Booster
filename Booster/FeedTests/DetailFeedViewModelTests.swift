//
//  DetailFeedViewModelTests.swift
//  FeedTests
//
//  Created by hiju on 2021/11/29.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

final class DetailFeedViewModelTests: XCTestCase {
    private var viewModel: DetailFeedViewModel!
    private var feedUsecase: FeedUseCase!
    private var milestone: Milestone!
    private var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
        feedUsecase = FeedUseCase()
        viewModel = DetailFeedViewModel(start: Date(), usecase: DetailFeedUsecase())
    }

    func test_모델에없는_마일스톤_nil받기_성공() throws {
        // given
        let expectation = expectation(description: "Fetch")
        feedUsecase.fetch()
            .bind { value in
                guard let startDate = value.first?.startDate
                else { return XCTAssert(false, "startDate값이 없습니다") }
                self.viewModel = DetailFeedViewModel(start: startDate, usecase: DetailFeedUsecase())
                //when
                let value = self.viewModel.milestone(at: Coordinate(latitude: 23.12421, longitude: 35.1232))
                //then
                XCTAssertNil(value, "값이 있습니다")
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 2)
    }
    
    func test_트래킹_모델_새로운값_업데이트_성공() throws {
        // given
        viewModel.trackingModel
            .skip(1)
            .bind { value in
                // then
                XCTAssertTrue(value.calories == 30 && value.distance == 21.42)
            }
            .disposed(by: disposeBag)

        var trackingModel = viewModel.trackingModel.value
        trackingModel.calories = 30
        trackingModel.distance = 21.42
        // when
        viewModel.trackingModel.accept(trackingModel)
    }
    
    func test_피드리스트_fetch_성공() throws {
        // given
        let expectation = expectation(description: "Fetch")
        viewModel.trackingModel
            .skip(1)
            .bind { _ in
                //then
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        feedUsecase.fetch()
            .bind { value in
                guard let startDate = value.first?.startDate
                else { return }
                self.viewModel = DetailFeedViewModel(start: startDate, usecase: DetailFeedUsecase())
                //when
                self.viewModel.fetchDetailFeedList()
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 2)
    }
    
    func test_수정피드뷰모델_생성_성공() throws {
        let modifyFeedViewModel = viewModel.createModifyFeedViewModel()
        XCTAssertNotNil(modifyFeedViewModel)
    }
    
    func test_마일스톤_제거_성공() throws {
        let expectation = expectation(description: "Fetch")
        
        //given
        feedUsecase.fetch()
            .bind { value in
                guard let startDate = value.last?.startDate
                else { return XCTAssert(false, "startDate가 존재하지 않습니다") }
                self.viewModel = DetailFeedViewModel(start: startDate, usecase: DetailFeedUsecase())
                sleep(2)
                guard let milestone = self.viewModel.trackingModel.value.milestones.first
                else { return XCTAssert(false, "트래킹모델 마일스톤 데이터가 없습니다") }
                
                self.viewModel.isDeletedMilestone
                    .bind { isDeleted in
                        //then
                        XCTAssertTrue(isDeleted)
                        expectation.fulfill()
                    }
                    .disposed(by: self.disposeBag)
                
                //when
                self.viewModel.remove(of: milestone)
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5)
    }
    
    func test_하나의_기록_삭제_성공() {
        let expectation = expectation(description: "Fetch")
        
        //given
        feedUsecase.fetch()
            .bind { value in
                guard let startDate = value.first?.startDate
                else { return XCTAssert(false, "startDate가 존재하지 않습니다") }
                self.viewModel = DetailFeedViewModel(start: startDate, usecase: DetailFeedUsecase())
                sleep(2)
                
                self.viewModel.isDeletedAll
                    .bind { isDeleted in
                        //then
                        XCTAssertTrue(isDeleted)
                        expectation.fulfill()
                    }
                    .disposed(by: self.disposeBag)
                
                //when
                self.viewModel.removeAll()
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5)
    }

    func test_그래디언트_컬러_coordinate_오프셋_찾기_실패() throws {
        //when
        let coordinate = viewModel.offsetOfGradientColorCoordinate()
        //then
        XCTAssertNil(coordinate, "오프셋 값이 있습니다")
    }
    
    func test_그래디언트_컬러_coordinate_오프셋_찾기_성공() throws {
        let expectation = expectation(description: "Fetch")
        
        //given
        feedUsecase.fetch()
            .bind { value in
                guard let startDate = value.last?.startDate
                else { return XCTAssert(false, "startDate가 존재하지 않습니다") }
                self.viewModel = DetailFeedViewModel(start: startDate, usecase: DetailFeedUsecase())
                sleep(2)
                
                //when
                let coordinate = self.viewModel.offsetOfGradientColorCoordinate()
                //then
                XCTAssertNotNil(coordinate, "오프셋 값이 없습니다")
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5)
    }
    
    func test_coordinate_인덱스_비율_찾기_성공() throws {
        let expectation = expectation(description: "Fetch")
        
        //given
        feedUsecase.fetch()
            .bind { value in
                guard let startDate = value.last?.startDate
                else { return XCTAssert(false, "startDate가 존재하지 않습니다") }
                self.viewModel = DetailFeedViewModel(start: startDate, usecase: DetailFeedUsecase())
                sleep(2)
                
                //when
                let index = abs(self.viewModel.trackingModel.value.coordinates.count - 2)
                let ratio = self.viewModel.indexRatioOfCoordinate(self.viewModel.trackingModel.value.coordinates[index]!)
                //then
                XCTAssertNotNil(ratio, "인덱스 비율값이 없습니다")
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5)
    }
}


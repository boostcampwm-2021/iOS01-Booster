//
//  UserViewModelTests.swift
//  UserTests
//
//  Created by mong on 2021/11/29.
//

import XCTest
import RxSwift

class UserViewModelTests: XCTestCase {
    var disposeBag: DisposeBag!
    var viewModel: UserViewModel!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        viewModel = UserViewModel()
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        viewModel = nil
    }

    func test_유저정보_전체_삭제_성공() throws {
        // given
        let expect = expectation(description: "removeAllData")

        // when
        viewModel.removeAllData()
            .subscribe(onNext: { isRemoved in
                
                // then
                XCTAssertTrue(isRemoved, "유저 정보 전체 삭제에 실패하였습니다.")
                expect.fulfill()
            }).disposed(by: disposeBag)
                       
        wait(for: [expect], timeout: 3)
    }
    
    func test_유저정보_수정_성공() throws {
        // given
        let expect = expectation(description: "editUserInfo")
        let newModel = UserInfo(age: 12,
                                nickname: "test",
                                gender: "남",
                                height: 169,
                                weight: 22)
        
        viewModel.model
            .take(2)
            .skip(1)
            .subscribe(onNext: { userInfo in
                
                // then
                let isEqual = ((userInfo.nickname == newModel.nickname) &&
                              (userInfo.height == newModel.height) &&
                              (userInfo.weight == newModel.weight) &&
                              (userInfo.age == newModel.age) &&
                              (userInfo.gender == newModel.gender))
                XCTAssertTrue(isEqual, "유저 정보 수정에 실패하였습니다.")
                expect.fulfill()
            }).disposed(by: disposeBag)
        
        // when
        viewModel.editUserInfo(gender: newModel.gender,
                                   age: newModel.age,
                                   height: newModel.height,
                                   weight: newModel.weight,
                                   nickname: newModel.nickname)
        
        wait(for: [expect], timeout: 3)
    }
    
    func test_목표_걸음수_변경_성공() throws {
        // given
        let expect = expectation(description: "changeGoal")
        let changeGoalValue = 22
        
        // when
        viewModel.changeGoal(to: changeGoalValue)
            .subscribe(onNext: { isChanged in
                
                // then
                XCTAssertTrue(isChanged, "목표 걸음수 변경에 실패하였습니다.")
                expect.fulfill()
            }).disposed(by: disposeBag)
        
        wait(for: [expect], timeout: 3)
    }
}

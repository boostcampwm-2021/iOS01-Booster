//
//  UserViewModelTests.swift
//  UserTests
//
//  Created by mong on 2021/11/29.
//

import XCTest
import RxSwift
import RxRelay
import RxTest

class UserViewModelTests: XCTestCase {
    var disposeBag: DisposeBag!
    var userViewModel: UserViewModel!
    var scheduler: TestScheduler!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        userViewModel = UserViewModel()
        scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        userViewModel = nil
        scheduler = nil
    }

    func test_유저정보_수정_성공() throws {
        var resultUserInfo: UserInfo?
        let newUserInfo = UserInfo(age: 99,
                                   nickname: "test",
                                   gender: "남",
                                   height: 111,
                                   weight: 11,
                                   goal: 1)
        
        userViewModel.editUserInfo(gender: newUserInfo.gender,
                                   age: newUserInfo.age,
                                   height: newUserInfo.height,
                                   weight: newUserInfo.weight,
                                   nickname: newUserInfo.nickname)
        
        userViewModel.model
            .subscribe(onNext: { userInfo in
                resultUserInfo = userInfo
            }).disposed(by: disposeBag)
        
        XCTAssertEqual(resultUserInfo?.nickname, newUserInfo.nickname, "유저 정보가 수정되지 않았습니다.")
    }
}

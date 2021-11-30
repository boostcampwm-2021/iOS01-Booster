//
//  NotificationSettingViewModel.swift
//  UserTests
//
//  Created by mong on 2021/11/30.
//

import XCTest
import RxSwift

class NotificationSettingViewModelTests: XCTestCase {
    var disposeBag: DisposeBag!
    var viewModel: NotificationSettingViewModel!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        viewModel = NotificationSettingViewModel()
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        viewModel = nil
    }
    
    func test_초기화_기본() throws {
        // given
        let model = viewModel.model.value
        let isEqual = ((model.title == "") &&
                       (model.subTitle == "") &&
                       (model.imageName == "") &&
                       (model.buttonBackgroundColorName == "") &&
                       (model.buttonAttributedTitle == NSAttributedString()) &&
                       (model.buttonTintColorName == ""))
        
        // when
        viewModel = NotificationSettingViewModel()
        
        // then
        XCTAssertTrue(isEqual, "초기화에 실패하였습니다.")
    }
    
    func test_초기화_알람상태_켜기() throws {
        // given
        viewModel = NotificationSettingViewModel(state: .on)
        let model = viewModel.model.value
        let resultModel = NotificationSettingViewModel.NotificationSettingModel(title: "현재 알림이 켜져있어요",
                                                                                subTitle: "좋은 소식들을\n들려드리기 위해 열심히 노력하고 있어요!",
                                                                                imageName: "notificationOn",
                                                                                buttonBackgroundColorName: "boosterEnableButtonGray",
                                                                                buttonAttributedTitle: NSAttributedString(string: "알림 끄기"),
                                                                                buttonTintColorName: "boosterGray")
        // when
        let isEqual = ((model.title == resultModel.title) &&
                       (model.subTitle == resultModel.subTitle) &&
                       (model.imageName == resultModel.imageName) &&
                       (model.buttonBackgroundColorName == resultModel.buttonBackgroundColorName) &&
                       (model.buttonAttributedTitle == resultModel.buttonAttributedTitle) &&
                       (model.buttonTintColorName == resultModel.buttonTintColorName))
        
        // then
        XCTAssertTrue(isEqual, "초기화(알람상태켜기)에 실패하였습니다.")
    }
    
    func test_초기화_알람상태_끄기() throws {
        // given
        viewModel = NotificationSettingViewModel(state: .off)
        let model = viewModel.model.value
        let resultModel = NotificationSettingViewModel.NotificationSettingModel(title: "현재 알림이 꺼져있어요",
                                                                                subTitle: "알람을 키면\n좋은 소식들을 가득 들려드릴게요",
                                                                                imageName: "notificationOff",
                                                                                buttonBackgroundColorName: "boosterOrange",
                                                                                buttonAttributedTitle: NSAttributedString(string: "알림 켜기"),
                                                                                buttonTintColorName: "boosterBlackLabel")
        // when
        
        let isEqual = ((model.title == resultModel.title) &&
                       (model.subTitle == resultModel.subTitle) &&
                       (model.imageName == resultModel.imageName) &&
                       (model.buttonBackgroundColorName == resultModel.buttonBackgroundColorName) &&
                       (model.buttonAttributedTitle == resultModel.buttonAttributedTitle) &&
                       (model.buttonTintColorName == resultModel.buttonTintColorName))
        
        // then
        XCTAssertTrue(isEqual, "초기화(알람상태끄기)에 실패하였습니다.")
    }
    
    func test_알람설정_상태_켜기() throws {
        // given
        let expect = expectation(description: "notificationOff")
        let resultModel = NotificationSettingViewModel.NotificationSettingModel(title: "현재 알림이 켜져있어요",
                                                                                subTitle: "좋은 소식들을\n들려드리기 위해 열심히 노력하고 있어요!",
                                                                                imageName: "notificationOn",
                                                                                buttonBackgroundColorName: "boosterEnableButtonGray",
                                                                                buttonAttributedTitle: NSAttributedString(string: "알림 끄기"),
                                                                                buttonTintColorName: "boosterGray")
        // then
        viewModel.model
            .take(2)
            .skip(1)
            .subscribe(onNext: { model in
                let isEqual = ((model.title == resultModel.title) &&
                               (model.subTitle == resultModel.subTitle) &&
                               (model.imageName == resultModel.imageName) &&
                               (model.buttonBackgroundColorName == resultModel.buttonBackgroundColorName) &&
                               (model.buttonAttributedTitle == resultModel.buttonAttributedTitle) &&
                               (model.buttonTintColorName == resultModel.buttonTintColorName))
                XCTAssertTrue(isEqual, "알림 설정 상태가 켜기 상태가 아닙니다.")
                expect.fulfill()
            }).disposed(by: disposeBag)
        
        // when
        viewModel.setState(to: .on)
        wait(for: [expect], timeout: 3)
    }
    
    func test_알람설정_상태_끄기() throws {
        let expect = expectation(description: "notificationOn")
        let resultModel = NotificationSettingViewModel.NotificationSettingModel(title: "현재 알림이 꺼져있어요",
                                                                                subTitle: "알람을 키면\n좋은 소식들을 가득 들려드릴게요",
                                                                                imageName: "notificationOff",
                                                                                buttonBackgroundColorName: "boosterOrange",
                                                                                buttonAttributedTitle: NSAttributedString(string: "알림 켜기"),
                                                                                buttonTintColorName: "boosterBlackLabel")
        // then
        viewModel.model
            .take(2)
            .skip(1)
            .subscribe(onNext: { model in
                let isEqual = ((model.title == resultModel.title) &&
                               (model.subTitle == resultModel.subTitle) &&
                               (model.imageName == resultModel.imageName) &&
                               (model.buttonBackgroundColorName == resultModel.buttonBackgroundColorName) &&
                               (model.buttonAttributedTitle == resultModel.buttonAttributedTitle) &&
                               (model.buttonTintColorName == resultModel.buttonTintColorName))
                XCTAssertTrue(isEqual, "알림 설정 상태가 끄기 상태가 아닙니다.")
                expect.fulfill()
            }).disposed(by: disposeBag)
        
        // when
        viewModel.setState(to: .off)
        wait(for: [expect], timeout: 3)
    }
}

//
//  NotificationSettingViewModel.swift
//  UserTests
//
//  Created by mong on 2021/11/30.
//

import XCTest
import RxSwift
@testable import Booster

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
    
    func test_알람설정_상태_끄기() throws {

    }
    
    func test_알람설정_상태_켜기() throws {
        
    }
}

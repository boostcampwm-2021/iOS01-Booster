//
//  NotificationSettingViewModel.swift
//  Booster
//
//  Created by mong on 2021/11/23.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

final class NotificationSettingViewModel {
    enum NotificationState {
        case on
        case off
    }

    struct NotificationSettingModel {
        var title = ""
        var subTitle = ""
        var imageName = ""
        var buttonBackgroundColorName = ""
        var buttonAttributedTitle: NSAttributedString = NSAttributedString()
        var buttonTintColorName = ""
    }

    private(set) var model = BehaviorRelay<NotificationSettingModel>(value: NotificationSettingModel())
    private let disposeBag = DisposeBag()
    private var notificationState = PublishRelay<NotificationState?>()

    init() {
        bind()
    }
    
    init(state: NotificationState) {
        bind()
        notificationState.accept(state)
    }

    func setState(to state: NotificationState) {
        notificationState.accept(state)
    }
    
    private func bind() {
        notificationState
            .bind(onNext: { [weak self] state in
                guard let self = self
                else { return }
                
                var newModel = self.model.value
                switch state {
                case .on:
                    newModel.title = "현재 알림이 켜져있어요"
                    newModel.subTitle = "좋은 소식들을 들려드리기 위해\n열심히 노력하고 있어요!"
                    newModel.imageName = "notificationOn"
                    newModel.buttonBackgroundColorName = "boosterEnableButtonGray"
                    newModel.buttonAttributedTitle = NSAttributedString(string: "알림 끄기")
                    newModel.buttonTintColorName = "boosterGray"
                case .off, .none:
                    newModel.title = "현재 알림이 꺼져있어요"
                    newModel.subTitle = "알람을 키면 좋은 소식들을\n가득 들려드릴게요"
                    newModel.imageName = "notificationOff"
                    newModel.buttonBackgroundColorName = "boosterOrange"
                    newModel.buttonAttributedTitle = NSAttributedString(string: "알림 켜기")
                    newModel.buttonTintColorName = "boosterBlackLabel"
                }
                self.model.accept(newModel)
            }).disposed(by: disposeBag)
    }
}

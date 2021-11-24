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
        var title: String = ""
        var subTitle: String = ""
        var image: UIImage = UIImage()
        var buttonBackgroundColor: UIColor = .systemBackground
        var buttonAttributedTitle: NSAttributedString = NSAttributedString()
        var buttonTintColor: UIColor = .boosterLabel
    }

    private(set) var model = BehaviorRelay<NotificationSettingModel>(value: NotificationSettingModel())
    private var notificationState: NotificationState?

    init() {}
    init(state: NotificationState) {
        notificationState = state
        setState(to: state)
    }

    func setState(to state: NotificationState) {
        (notificationState == state) ? () : changeModelValue(state: state)
    }

    private func changeModelValue(state: NotificationState) {
        var newModel = model.value
        switch state {
        case .on:
            newModel.title = "현재 알림이 켜져있어요"
            newModel.subTitle = "좋은 소식들을\n들려드리기 위해 열심히 노력하고 있어요!"
            newModel.image = UIImage.notificationOn
            newModel.buttonBackgroundColor = .boosterEnableButtonGray
            newModel.buttonAttributedTitle = NSAttributedString(string: "알림 끄기")
            newModel.buttonTintColor = .boosterGray
        case .off:
            newModel.title = "현재 알림이 꺼져있어요"
            newModel.subTitle = "알람을 키면\n좋은 소식들을 가득 들려드릴게요"
            newModel.image = UIImage.notificationOff
            newModel.buttonBackgroundColor = .boosterOrange
            newModel.buttonAttributedTitle = NSAttributedString(string: "알림 켜기")
            newModel.buttonTintColor = .boosterBlackLabel
        }
        model.accept(newModel)
    }
}

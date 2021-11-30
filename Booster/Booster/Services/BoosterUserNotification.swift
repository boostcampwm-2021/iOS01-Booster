//
//  BoosterNotification.swift
//  Booster
//
//  Created by mong on 2021/11/29.
//

import UIKit

final class BoosterUserNotification {
    enum NotificationType: String {
        case morning
        case goal
    }
    
    enum NotificationRequestType {
        case add
        case remove
    }
    
    private let notificationContent = UNMutableNotificationContent()
    
    func isAlreadyAdded(type: NotificationType) -> Bool {
        var isAdded = false
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
            requests.forEach {
                if $0.identifier == type.rawValue {
                    isAdded = true
                    return
                }
            }
        })
        
        return isAdded
    }
    
    func setNotification(requestType: NotificationRequestType, type: NotificationType) {
        switch requestType {
        case .add:
            addNotification(type: type)
        case .remove:
            removeNotification(type: type)
        }
    }
    
    private func addNotification(type: NotificationType) {
        switch type {
        case .morning:
            addMorningNotification()
        case .goal:
            addGoalNotification()
        }
    }
    
    private func removeNotification(type: NotificationType) {
        switch type {
        case .morning:
            removeMorningNotification()
        case .goal:
            removeGoalNotification()
        }
    }
    
    private func addMorningNotification() {
        let title = "아침이 밝았어요!"
        let body = "오늘 하루도 산책으로 분위기를 환기시키는게 어때요?"
        notificationContent.title = title
        notificationContent.body = body

        var dateComponents = DateComponents()
        dateComponents.hour = 9

        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let notificationRequest = UNNotificationRequest(identifier: NotificationType.morning.rawValue,
                                                        content: notificationContent,
                                                        trigger: notificationTrigger)

        UNUserNotificationCenter.current().add(notificationRequest) { error in
            
        }
    }
    
    private func removeMorningNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationType.morning.rawValue])
    }
    
    private func addGoalNotification() {
        let title = "축하합니다!"
        let body = "목표 걸음수에 도달했어요!"
        notificationContent.title = title
        notificationContent.body = body

        
        let notificationRequest = UNNotificationRequest(identifier: NotificationType.goal.rawValue,
                                                        content: notificationContent,
                                                        trigger: nil)

        UNUserNotificationCenter.current().add(notificationRequest) { [weak self] error in
            self?.removeGoalNotification()
        }
    }
    
    private func removeGoalNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationType.goal.rawValue])
    }
}

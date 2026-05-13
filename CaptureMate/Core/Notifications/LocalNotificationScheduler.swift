//
//  LocalNotificationScheduler.swift
//  CaptureMate
//
//  Created by Codex on 5/10/26.
//

import UIKit
import UserNotifications

final class LocalNotificationScheduler {
    static let shared = LocalNotificationScheduler()

    private let notificationCenter: UNUserNotificationCenter
    private let dailyCaptureCheckIdentifier = "daily-capture-check"

    private init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    func scheduleIfAlreadyAllowed() {
        NotificationPermissionManager.shared.checkAuthorizationStatus { [weak self] isAllowed in
            guard isAllowed else { return }
            self?.scheduleDailyCaptureCheckNotification()
        }
    }

    func resetBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    func scheduleDailyCaptureCheckNotification() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [dailyCaptureCheckIdentifier]
        )

        let content = UNMutableNotificationContent()
        content.title = "새로운 캡쳐를 확인해보세요"
        content.body = "오늘 저장된 스크린샷에서 장소, 쿠폰, 일정을 정리할 시간이에요."
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "destination": "home"
        ]

        // 실제 배포용: 매일 밤 10시
        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        // 테스트용: 10초 뒤 알림
//        let trigger = UNTimeIntervalNotificationTrigger(
//            timeInterval: 10,
//            repeats: false
//        )

        let request = UNNotificationRequest(
            identifier: dailyCaptureCheckIdentifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error {
                print("Daily capture check notification scheduling failed: \(error.localizedDescription)")
            }
        }
    }
}

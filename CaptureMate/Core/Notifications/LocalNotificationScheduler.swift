//
//  LocalNotificationScheduler.swift
//  CaptureMate
//
//  Created by Codex on 5/10/26.
//

import Foundation
import UIKit
import UserNotifications

final class LocalNotificationScheduler {
    static let shared = LocalNotificationScheduler()

    private let notificationCenter: UNUserNotificationCenter
    private let dailyCaptureCheckIdentifier = "daily-capture-check"
    private let initialPermissionRequestKey = "hasRequestedInitialNotificationPermission"

    private init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    var hasRequestedInitialPermission: Bool {
        UserDefaults.standard.bool(forKey: initialPermissionRequestKey)
    }

    func requestInitialPermissionAfterSignUp(completion: @escaping (Bool) -> Void) {
        guard !hasRequestedInitialPermission else {
            checkAuthorizationStatus(completion: completion)
            return
        }

        UserDefaults.standard.set(true, forKey: initialPermissionRequestKey)

        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            if let error {
                print("Local notification authorization failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            if granted {
                self?.scheduleDailyCaptureCheckNotification()
            }

            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleIfAlreadyAllowed() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self?.scheduleDailyCaptureCheckNotification()
            default:
                break
            }
        }
    }

    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            let isAllowed: Bool

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                isAllowed = true
            default:
                isAllowed = false
            }

            DispatchQueue.main.async {
                completion(isAllowed)
            }
        }
    }

    func openAppNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }

    func resetBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    private func scheduleDailyCaptureCheckNotification() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyCaptureCheckIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "새로운 캡쳐를 확인해보세요"
        content.body = "오늘 저장된 스크린샷에서 장소, 쿠폰, 일정을 정리할 시간이에요."
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
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

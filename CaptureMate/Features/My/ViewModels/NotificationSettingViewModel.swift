//
//  NotificationSettingViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 6/11/26.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationSettingViewModel: ObservableObject {
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined

    @Published var isAppNotificationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isAppNotificationEnabled, forKey: "isAppNotificationEnabled")
        }
    }

    init() {
        self.isAppNotificationEnabled =
            UserDefaults.standard.object(forKey: "isAppNotificationEnabled") as? Bool ?? true
    }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            self.checkNotificationStatus()
        }
    }

    var isSystemNotificationAllowed: Bool {
        notificationStatus == .authorized ||
        notificationStatus == .provisional ||
        notificationStatus == .ephemeral
    }

    var statusMessage: String {
        switch notificationStatus {
        case .authorized:
            return "iPhone 알림 권한이 허용되어 있어요."
        case .denied:
            return "iPhone 알림 권한이 꺼져 있어요."
        case .notDetermined:
            return "아직 알림 권한을 요청하지 않았어요."
        case .provisional:
            return "임시 알림 권한이 허용되어 있어요."
        case .ephemeral:
            return "일시적 알림 권한이 허용되어 있어요."
        @unknown default:
            return "알림 권한 상태를 확인할 수 없어요."
        }
    }
}

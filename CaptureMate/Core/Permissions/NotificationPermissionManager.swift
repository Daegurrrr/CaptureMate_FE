//
//  NotificationPermissionManager.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/12/26.
//

import UIKit

import UserNotifications

final class NotificationPermissionManager {

    static let shared = NotificationPermissionManager()

    private let notificationCenter: UNUserNotificationCenter

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

        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in

            if let error {

                print("Local notification authorization failed: \(error.localizedDescription)")

                DispatchQueue.main.async {

                    completion(false)

                }

                return

            }

            DispatchQueue.main.async {

                completion(granted)

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

}

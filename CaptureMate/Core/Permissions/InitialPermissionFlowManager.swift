//
//  InitialPermissionFlowManager.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

final class InitialPermissionFlowManager {

    static let shared = InitialPermissionFlowManager()

    private init() {}

    private let screenshotStartDateKey = "screenshotStartDate"
    private let hasCompletedInitialPermissionKey = "hasCompletedInitialPermission"

    var hasCompletedInitialPermission: Bool {
        UserDefaults.standard.bool(
            forKey: hasCompletedInitialPermissionKey
        )
    }

    func markCompleted() {
        UserDefaults.standard.set(
            true,
            forKey: hasCompletedInitialPermissionKey
        )
    }

    func saveScreenshotStartDate(_ date: Date) {

        UserDefaults.standard.set(
            date,
            forKey: screenshotStartDateKey
        )

        NotificationCenter.default.post(
            name: NSNotification.Name("ScreenshotDataUpdated"),
            object: nil
        )
    }
}

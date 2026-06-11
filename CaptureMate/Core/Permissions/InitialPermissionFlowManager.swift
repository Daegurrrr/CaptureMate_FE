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

    var screenshotStartDate: Date? {
        UserDefaults.standard.object(
            forKey: screenshotStartDateKey
        ) as? Date
    }

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

        print("초기 권한 플로우 완료 저장")
    }

    func saveScreenshotStartDate(_ date: Date) {
        UserDefaults.standard.set(
            date,
            forKey: screenshotStartDateKey
        )

        print("스크린샷 시작 날짜 저장:", date)
        print("저장 후 시작 날짜 확인:", screenshotStartDate as Any)

        NotificationCenter.default.post(
            name: NSNotification.Name("ScreenshotDataUpdated"),
            object: nil
        )
    }
}

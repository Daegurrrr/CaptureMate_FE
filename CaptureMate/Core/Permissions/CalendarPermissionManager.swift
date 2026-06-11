//
//  CalendarPermissionManager.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/29/26.
//

import EventKit

final class CalendarPermissionManager {
    static let shared = CalendarPermissionManager()

    private init() {}

    func requestPermission(store: EKEventStore) async -> Bool {
        do {
            return try await store.requestFullAccessToEvents()
        } catch {
            print("캘린더 권한 요청 실패:", error.localizedDescription)
            return false
        }
    }
}

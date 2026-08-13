//
//  CalendarService.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/29/26.
//

import Foundation
import EventKit
import UIKit

final class CalendarService {

    static let shared = CalendarService()

    private let store = EKEventStore()

    private init() {}

    enum SaveResult {
        case success
        case permissionDenied
        case failure
    }

    func addEvent(
        title: String,
        startDate: Date,
        endDate: Date
    ) async -> Bool {
        await addEventWithResult(
            title: title,
            startDate: startDate,
            endDate: endDate
        ) == .success
    }

    func addEventWithResult(
        title: String,
        startDate: Date,
        endDate: Date
    ) async -> SaveResult {

        guard await requestCalendarAccessIfNeeded() else {
            print("캘린더 권한 없음")
            return .permissionDenied
        }

        do {
            let event =
                EKEvent(eventStore: store)

            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.calendar =
                store.defaultCalendarForNewEvents

            try store.save(
                event,
                span: .thisEvent
            )

            print("캘린더 저장 성공")

            return .success

        } catch {

            print(
                "캘린더 저장 실패:",
                error.localizedDescription
            )

            return .failure
        }
    }

    private func requestCalendarAccessIfNeeded() async -> Bool {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess, .writeOnly:
            return true

        case .notDetermined:
            do {
                return try await store.requestFullAccessToEvents()
            } catch {
                print(
                    "캘린더 권한 요청 실패:",
                    error.localizedDescription
                )
                return false
            }

        case .authorized:
            return true

        case .denied, .restricted:
            return false

        @unknown default:
            return false
        }
    }

    @MainActor
    func openAppSettings() {
        guard let url = URL(
            string: UIApplication.openSettingsURLString
        ) else {
            return
        }

        UIApplication.shared.open(url)
    }

    @MainActor
    func openCalendarApp(
        at date: Date
    ) {

        let timestamp =
            date.timeIntervalSinceReferenceDate

        guard let url =
                URL(
                    string:
                    "calshow:\(timestamp)"
                )
        else {
            return
        }

        UIApplication.shared.open(url)
    }
}

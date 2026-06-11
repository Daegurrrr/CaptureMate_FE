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

    func addEvent(
        title: String,
        startDate: Date,
        endDate: Date
    ) async -> Bool {

        do {

            let granted =
                try await store.requestFullAccessToEvents()

            guard granted else {

                print("캘린더 권한 없음")
                return false
            }

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

            return true

        } catch {

            print(
                "캘린더 저장 실패:",
                error.localizedDescription
            )

            return false
        }
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

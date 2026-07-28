//
//  RecommendedActionCard.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct RecommendedActionCard: View {

    let actions: [RecommendedAction]
    let onDelete: (RecommendedAction) -> Void
    let onOpenExternalLink: (RecommendedAction) -> Void
    let onCompleteAction: (RecommendedAction) -> Void

    @State private var pendingScheduleAction: RecommendedAction?
    @State private var showCalendarAlert = false

    var body: some View {
        VStack(spacing: 0) {
            if actions.isEmpty {
                Text("추천 액션이 아직 없어요")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                ForEach(actions) { action in
                    RecommendedActionRow(
                        action: action,
                        onTap: {
                            handleAction(action)
                        },
                        onDelete: {
                            onDelete(action)
                        }
                    )

                    if action.id != actions.last?.id {
                        Divider()
                            .padding(.leading, 46)
                    }
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .alert("캘린더에 저장할까요?", isPresented: $showCalendarAlert) {
            Button("취소", role: .cancel) {}

            Button("저장") {
                savePendingSchedule()
            }
        } message: {
            Text(pendingScheduleAction?.title ?? "")
        }
    }

    private func handleAction(_ action: RecommendedAction) {
        switch action.type {

        case .place, .shopping:
            guard let urlString = action.url,
                  let url = URL(string: urlString) else {
                return
            }
            onOpenExternalLink(action)
            UIApplication.shared.open(url)

        case .schedule:
            pendingScheduleAction = action
            showCalendarAlert = true
        }
    }

    private func savePendingSchedule() {
        guard let action = pendingScheduleAction,
              let startDate = action.startDate else {
            print("일정 시작 시간이 없음")
            return
        }

        let endDate = action.endDate ?? Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: startDate
        ) ?? startDate

        Task {
            let success = await CalendarService.shared.addEvent(
                title: action.title,
                startDate: startDate,
                endDate: endDate
            )

            if success {
                await MainActor.run {
                    onCompleteAction(action)
                }
                
                await CalendarService.shared.openCalendarApp(
                    at: startDate
                )
            }
        }
    }
}

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

    @State private var pendingScheduleAction: RecommendedAction?
    @State private var showCalendarAlert = false
    @State private var showCalendarPermissionAlert = false
    @State private var showCalendarSaveFailedAlert = false

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
        .alert("캘린더 권한이 필요해요", isPresented: $showCalendarPermissionAlert) {
            Button("취소", role: .cancel) {}

            Button("설정 열기") {
                Task {
                    await CalendarService.shared.openAppSettings()
                }
            }
        } message: {
            Text("일정을 저장하려면 설정에서 캘린더 접근 권한을 허용해주세요.")
        }
        .alert("캘린더 저장에 실패했어요", isPresented: $showCalendarSaveFailedAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("잠시 후 다시 시도해주세요.")
        }
    }

    private func handleAction(_ action: RecommendedAction) {
        switch action.type {

        case .place:
            guard let urlString = action.url,
                  let url = URL(string: urlString) else {
                print("장소 추천 액션 URL 없음:", action.title)
                return
            }
            UIApplication.shared.open(url) { success in
                guard !success,
                      let fallbackURLString = action.fallbackURL,
                      let fallbackURL = URL(string: fallbackURLString) else {
                    return
                }

                UIApplication.shared.open(fallbackURL)
            }
            onDelete(action)

        case .shopping:
            guard let urlString = action.url,
                  let url = URL(string: urlString) else {
                print("쇼핑 추천 액션 URL 없음:", action.title)
                return
            }
            UIApplication.shared.open(url)
            onDelete(action)

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
            let result = await CalendarService.shared.addEventWithResult(
                title: action.title,
                startDate: startDate,
                endDate: endDate
            )

            switch result {
            case .success:
                await CalendarService.shared.openCalendarApp(
                    at: startDate
                )

                await MainActor.run {
                    onDelete(action)
                    pendingScheduleAction = nil
                }

            case .permissionDenied:
                await MainActor.run {
                    showCalendarPermissionAlert = true
                }

            case .failure:
                await MainActor.run {
                    showCalendarSaveFailedAlert = true
                }
            }
        }
    }
}

//
//  HomeView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    @State private var showsPermissionAlert = false
    @State private var showScreenshotStartDateDialog = false

    let actions: [RecommendedAction] = [
        RecommendedAction(
            icon: "hourglass",
            title: "곧 만료되는 쿠폰",
            subtitle: "<스타벅스> 아메리카노 → D - 2"
        ),
        RecommendedAction(
            icon: "mappin",
            title: "감지된 장소",
            subtitle: "애니언 성수"
        ),
        RecommendedAction(
            icon: "calendar",
            title: "감지된 일정",
            subtitle: "신사 몬차치 팝업 → ~4월 30일"
        )
    ]

    var body: some View {
        let summary = CaptureSummary(
            totalCount: viewModel.todayScreenshotCount,
            placeCount: 0,
            couponCount: 0,
            otherCount: 0
        )

        return VStack(spacing: 0) {
            AppHeaderView(title: "Home")

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("오늘 감지된 캡쳐")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                    TodayCaptureSummaryCard(summary: summary)
                        .padding(.horizontal, 16)

                    Text("추천 액션")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 16)

                    RecommendedActionCard(actions: actions)
                        .padding(.horizontal, 16)

                    Spacer(minLength: 20)
                }
                .padding(.top, 10)
            }
            .background(Color(red: 245/255, green: 244/255, blue: 249/255))
        }
        .background(Color.white)
        .onAppear {
            viewModel.loadTodayScreenshotCount()
            requestInitialPermissionsIfNeeded()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification
            )
        ) { _ in
            viewModel.loadTodayScreenshotCount()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: NSNotification.Name("ScreenshotDataUpdated")
            )
        ) { _ in
            viewModel.loadTodayScreenshotCount()
        }
        .alert("권한 허용이 필요해요", isPresented: $showsPermissionAlert) {
            Button("나중에") {
                InitialPermissionFlowManager.shared.markCompleted()
            }

            Button("설정으로 이동") {
                InitialPermissionFlowManager.shared.markCompleted()
                NotificationPermissionManager.shared.openAppNotificationSettings()
            }
        } message: {
            Text("알림과 사진 접근 권한을 허용하면 새로운 캡쳐를 놓치지 않고 확인할 수 있어요.")
        }
        .confirmationDialog(
            "언제부터 캡쳐를 가져올까요?",
            isPresented: $showScreenshotStartDateDialog,
            titleVisibility: .visible
        ) {
            Button("오늘") {
                saveScreenshotStartDate(Calendar.current.startOfDay(for: Date()))
            }

            Button("3일 전부터") {
                let date = Calendar.current.date(
                    byAdding: .day,
                    value: -3,
                    to: Date()
                ) ?? Date()

                saveScreenshotStartDate(date)
            }

            Button("일주일 전부터") {
                let date = Calendar.current.date(
                    byAdding: .day,
                    value: -7,
                    to: Date()
                ) ?? Date()

                saveScreenshotStartDate(date)
            }

            Button("한 달 전부터") {
                let date = Calendar.current.date(
                    byAdding: .month,
                    value: -1,
                    to: Date()
                ) ?? Date()

                saveScreenshotStartDate(date)
            }

            Button("취소", role: .cancel) {
                InitialPermissionFlowManager.shared.markCompleted()
            }
        }
    }

    private func requestInitialPermissionsIfNeeded() {
        guard !InitialPermissionFlowManager.shared.hasCompletedInitialPermission else {
            return
        }

        NotificationPermissionManager.shared.requestInitialPermissionAfterSignUp { isNotificationAllowed in
            if isNotificationAllowed {
                LocalNotificationScheduler.shared.scheduleDailyCaptureCheckNotification()
            }

            PhotoPermissionManager.shared.requestPermission { isPhotoAllowed in
                if isPhotoAllowed {
                    showScreenshotStartDateDialog = true
                } else {
                    showsPermissionAlert = true
                }
            }
        }
    }

    private func saveScreenshotStartDate(_ date: Date) {
        InitialPermissionFlowManager.shared.saveScreenshotStartDate(date)
        InitialPermissionFlowManager.shared.markCompleted()
    }
}

//
//  HomeView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    @State private var showsPermissionAlert = false
    @State private var showScreenshotStartDateDialog = false
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let summary = CaptureSummary(
            totalCount: viewModel.todayScreenshotCount,
            placeShoppingCount: viewModel.placeCount + viewModel.shoppingCount,
            scheduleCount: viewModel.scheduleCount,
            memoCount: viewModel.memoCount
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

                    RecommendedActionCard(
                        actions: viewModel.recommendedActions,
                        onDelete: { action in
                            viewModel.removeAction(
                                action,
                                modelContext: modelContext
                            )
                        },
                        onOpenExternalLink: { action in
                            viewModel.markActionAsPendingOpened(action)
                        },
                        onCompleteAction: { action in
                            viewModel.removeAction(
                                action,
                                modelContext: modelContext
                            )
                        }
                    )
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
            viewModel.loadRecommendedActions(modelContext: modelContext)
            viewModel.loadCategoryCounts(modelContext: modelContext)
            requestInitialPermissionsIfNeeded()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification
            )
        ) { _ in
            viewModel.completePendingOpenedActionIfNeeded(modelContext: modelContext)
            viewModel.loadTodayScreenshotCount()
            viewModel.loadRecommendedActions(modelContext: modelContext)
            viewModel.loadCategoryCounts(modelContext: modelContext)
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: NSNotification.Name("ScreenshotDataUpdated")
            )
        ) { _ in
            viewModel.loadTodayScreenshotCount()
            viewModel.loadRecommendedActions(modelContext: modelContext)
            viewModel.loadCategoryCounts(modelContext: modelContext)
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
        let hasCompleted = InitialPermissionFlowManager.shared.hasCompletedInitialPermission
        let startDate = InitialPermissionFlowManager.shared.screenshotStartDate

        print("초기 권한 완료 여부:", hasCompleted)
        print("현재 저장된 스크린샷 시작 날짜:", startDate as Any)

        if startDate != nil {
            return
        }

        PhotoPermissionManager.shared.checkAuthorizationStatus { isPhotoAllowed in
            if isPhotoAllowed {
                showScreenshotStartDateDialog = true
                return
            }

            if hasCompleted {
                return
            }

            NotificationPermissionManager.shared.requestInitialPermissionAfterSignUp { isNotificationAllowed in
                if isNotificationAllowed {
                    LocalNotificationScheduler.shared.scheduleDailyCaptureCheckNotification()
                }

                PhotoPermissionManager.shared.requestPermission { isPhotoAllowed in
                    InitialPermissionFlowManager.shared.markCompleted()

                    if isPhotoAllowed {
                        showScreenshotStartDateDialog = true
                    } else {
                        showsPermissionAlert = true
                    }
                }
            }
        }
    }

    private func saveScreenshotStartDate(_ date: Date) {
        InitialPermissionFlowManager.shared.saveScreenshotStartDate(date)

        print(
            "HomeView 저장 후 시작 날짜:",
            InitialPermissionFlowManager.shared.screenshotStartDate as Any
        )

        InitialPermissionFlowManager.shared.markCompleted()

        NotificationCenter.default.post(
            name: NSNotification.Name("StartPhotoUploadAfterPermission"),
            object: nil
        )
    }
}

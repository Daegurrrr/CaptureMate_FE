//
//  RootView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject private var session: AppSession
    @Environment(\.modelContext) private var modelContext

    @State private var photoLibraryObserver: PhotoLibraryObserver?
    @State private var isShowingIntroSplash = true

    private let photoUploadService = PhotoUploadService()

    var body: some View {
        Group {
            if session.hasSeenIntro {
                MainTabView()
                    .task {
                        await startPhotoUploadFlow()
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(
                            for: NSNotification.Name("StartPhotoUploadAfterPermission")
                        )
                    ) { _ in
                        Task {
                            await startPhotoUploadFlow()
                        }
                    }

            } else {
                if isShowingIntroSplash {
                    IntroSplashView {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isShowingIntroSplash = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    IntroPagerView()
                        .transition(.opacity)
                }
            }
        }
    }

    private func startPhotoUploadFlow() async {
        let hasCompleted = InitialPermissionFlowManager.shared.hasCompletedInitialPermission
        let startDate = InitialPermissionFlowManager.shared.screenshotStartDate

        guard hasCompleted, startDate != nil else {
            print("초기 권한 플로우가 완료되지 않아 업로드 보류")
            return
        }

        PhotoPermissionManager.shared.requestPermission { isAllowed in
            guard isAllowed else {
                print("사진 권한 없음")
                return
            }

            Task { @MainActor in
                await photoUploadService.uploadNewPhotos(
                    modelContext: modelContext
                )

                if photoLibraryObserver == nil {
                    photoLibraryObserver = PhotoLibraryObserver(
                        modelContext: modelContext
                    )
                }
            }
        }
    }
}

private struct IntroSplashView: View {
    let onFinished: () -> Void

    @State private var hasStarted = false

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.98, blue: 0.99)
                .ignoresSafeArea()

            Image("splash_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 260)
        }
        .onAppear {
            guard !hasStarted else {
                return
            }

            hasStarted = true
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    onFinished()
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppSession())
}

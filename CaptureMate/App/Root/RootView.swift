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
                IntroPagerView()
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

#Preview {
    RootView()
        .environmentObject(AppSession())
}

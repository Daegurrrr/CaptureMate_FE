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
            if session.isLoggedIn {
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

            } else if !session.hasSeenIntro {
                IntroPagerView()

            } else {
                AuthEntryView()
            }
        }
    }

    private func startPhotoUploadFlow() async {
        PhotoPermissionManager.shared.requestPermission { isAllowed in
            guard isAllowed else {
                print("사진 권한 없음")
                return
            }

            let startDate = InitialPermissionFlowManager.shared.screenshotStartDate

            guard startDate != nil else {
                print("스크린샷 시작 날짜가 아직 없어 업로드 보류")
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

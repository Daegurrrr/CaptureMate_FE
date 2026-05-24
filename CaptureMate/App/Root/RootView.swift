//
//  RootView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI
import SwiftData
import Photos

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

            } else if !session.hasSeenIntro {
                IntroPagerView()

            } else {
                AuthEntryView()
            }
        }
    }

    private func startPhotoUploadFlow() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        guard status == .authorized || status == .limited else {
            print("사진 권한 없음")
            return
        }

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

#Preview {
    RootView()
        .environmentObject(AppSession())
}

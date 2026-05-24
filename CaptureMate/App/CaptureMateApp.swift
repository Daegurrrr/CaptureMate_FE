//
//  CaptureMateApp.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI
import SwiftData
import KakaoSDKCommon
import KakaoSDKAuth
import GoogleSignIn

@main
struct CaptureMateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var session = AppSession()
    @StateObject private var notificationRouter = NotificationRouter.shared

    init() {
        KakaoSDK.initSDK(appKey: Secrets.value(for: "KAKAO_NATIVE_APP_KEY"))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(notificationRouter)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                        return
                    }

                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    LocalNotificationScheduler.shared.scheduleIfAlreadyAllowed()
                    LocalNotificationScheduler.shared.resetBadge()
                }
        }
        .modelContainer(for: [
            PhotoUploadRecord.self,
            PhotoAnalysisRecord.self
        ])
    }
}

//
//  CaptureMateApp.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

@main
struct CaptureMateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var session = AppSession()
    @StateObject private var notificationRouter = NotificationRouter.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(notificationRouter)
                .onAppear {
                    LocalNotificationScheduler.shared.scheduleIfAlreadyAllowed()
                    LocalNotificationScheduler.shared.resetBadge()
                }
        }
    }
}

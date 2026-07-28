//
//  MyViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/12/26.
//

import Foundation

@MainActor
final class MyViewModel: ObservableObject {
    @Published var userName: String = "사용자"

    let menuItems: [MyMenuItem] = [
        MyMenuItem(
            title: "알림 설정",
            icon: "bell.fill",
            type: .notificationSetting
        ),
        MyMenuItem(
            title: "접근 권한 설정",
            icon: "lock.fill",
            type: .permissionSetting
        )
    ]
}

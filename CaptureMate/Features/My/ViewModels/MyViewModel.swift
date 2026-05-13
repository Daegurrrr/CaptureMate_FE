//
//  MyViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/12/26.
//

import Foundation

@MainActor
final class MyViewModel: ObservableObject {
    @Published var userName: String = "@@"

    let menuItems: [MyMenuItem] = [
        MyMenuItem(title: "프로필", icon: "star", type: .profile),
        MyMenuItem(title: "공지사항", icon: "star", type: .notice),
        MyMenuItem(title: "알림 설정", icon: "star", type: .notificationSetting),
        MyMenuItem(title: "접근 권한 설정", icon: "star", type: .permissionSetting),
        MyMenuItem(title: "버전 정보", icon: "star", type: .versionInfo),
        MyMenuItem(title: "...", icon: "star", type: .etc),
        MyMenuItem(title: "로그아웃", icon: "star", type: .logout),
        MyMenuItem(title: "탈퇴하기", icon: "star", type: .withdraw)
    ]

    func handleMenuTap(_ item: MyMenuItem) {
        switch item.type {
        case .profile:
            print("프로필 이동")

        case .notice:
            print("공지사항 이동")

        case .notificationSetting:
            print("알림 설정 이동")

        case .permissionSetting:
            print("접근 권한 설정 이동")

        case .versionInfo:
            print("버전 정보 이동")

        case .etc:
            print("기타 이동")

        case .logout:
            print("로그아웃")

        case .withdraw:
            print("탈퇴하기")
        }
    }
}

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

    private let authService = AuthService()

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
        ),
        MyMenuItem(
            title: "로그아웃",
            icon: "rectangle.portrait.and.arrow.right",
            type: .logout
        ),
        MyMenuItem(
            title: "탈퇴하기",
            icon: "person.crop.circle.badge.xmark",
            type: .withdraw
        )
    ]

    func handleMenuTap(
        _ item: MyMenuItem,
        onLogout: @escaping () -> Void
    ) {
        switch item.type {
        case .notificationSetting, .permissionSetting:
            break

        case .logout:
            logout(onLogout: onLogout)

        case .withdraw:
            print("탈퇴하기")
        }
    }

    private func logout(onLogout: @escaping () -> Void) {
        Task {
            do {
                try await authService.logout()
                print("Logout Success")
            } catch {
                print("Logout Failed:", error.localizedDescription)
            }

            UserDefaults.standard.removeObject(forKey: "accessToken")
            UserDefaults.standard.removeObject(forKey: "refreshToken")
            UserDefaults.standard.removeObject(forKey: "userId")

            onLogout()
        }
    }
}

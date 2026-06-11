//
//  NotificationSettingView.swift
//  CaptureMate
//
//  Created by 허채윤 on 6/11/26.
//

import SwiftUI

struct NotificationSettingView: View {
    @StateObject private var viewModel = NotificationSettingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            AppHeaderView(
                title: "알림 설정",
                showsBackButton: true,
                showsBellButton: false
            )

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("앱 내 추천 알림")
                        .font(.system(size: 17))

                    Spacer()

                    Toggle("", isOn: $viewModel.isAppNotificationEnabled)
                }

                HStack {
                    Text("iPhone 알림 권한")
                        .font(.system(size: 17))

                    Spacer()

                    Toggle("", isOn: .constant(viewModel.isSystemNotificationAllowed))
                        .disabled(true)
                }

                Text(viewModel.statusMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                if viewModel.notificationStatus == .denied {
                    Button("설정으로 이동") {
                        openAppSettings()
                    }
                    .buttonStyle(.borderedProminent)
                } else if viewModel.notificationStatus == .notDetermined {
                    Button("알림 권한 요청하기") {
                        viewModel.requestNotificationPermission()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.checkNotificationStatus()
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

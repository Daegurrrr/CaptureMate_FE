//
//  PermissionSettingView.swift
//  CaptureMate
//
//  Created by 허채윤 on 6/11/26.
//

import SwiftUI
import Photos

struct PermissionSettingView: View {
    @StateObject private var viewModel = PermissionSettingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            AppHeaderView(
                title: "접근 권한 설정",
                showsBackButton: true,
                showsBellButton: false
            )

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("사진 접근 권한")
                        .font(.system(size: 17))

                    Spacer()

                    Toggle("", isOn: .constant(viewModel.isPhotoPermissionAllowed))
                        .disabled(true)
                }

                Text(viewModel.photoStatusText)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Text("사진 접근 권한은 앱 내에서 직접 변경할 수 없어요.\niPhone 설정에서 CaptureMate의 사진 접근 권한을 변경해주세요.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Button {
                    openAppSettings()
                } label: {
                    Text("iPhone 설정으로 이동")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.checkPhotoPermission()
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

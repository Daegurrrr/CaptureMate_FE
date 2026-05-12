//
//  SignUpView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var session: AppSession

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var showsPermissionAlert = false
    @State private var showScreenshotStartDateDialog = false

    private let screenshotStartDateKey = "screenshotStartDate"

    var body: some View {
        VStack(spacing: 16) {
            Text("회원가입")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 40)

            TextField("이름", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("이메일", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("비밀번호", text: $password)
                .textFieldStyle(.roundedBorder)

            Button {
                requestPermissionsAfterSignUp()
            } label: {
                Text("회원가입 완료")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 24)
        .alert("권한 허용이 필요해요", isPresented: $showsPermissionAlert) {
            Button("나중에") {
                session.login()
            }

            Button("설정으로 이동") {
                session.login()
                NotificationPermissionManager.shared.openAppNotificationSettings()
            }
        } message: {
            Text("알림과 사진 접근 권한을 허용하면 새로운 캡쳐를 놓치지 않고 확인할 수 있어요.")
        }
        .confirmationDialog(
            "언제부터 캡쳐를 가져올까요?",
            isPresented: $showScreenshotStartDateDialog,
            titleVisibility: .visible
        ) {
            Button("오늘") {
                saveScreenshotStartDate(
                    Calendar.current.startOfDay(for: Date())
                )
            }

            Button("3일 전부터") {
                let date = Calendar.current.date(
                    byAdding: .day,
                    value: -3,
                    to: Date()
                ) ?? Date()

                saveScreenshotStartDate(date)
            }

            Button("일주일 전부터") {
                let date = Calendar.current.date(
                    byAdding: .day,
                    value: -7,
                    to: Date()
                ) ?? Date()

                saveScreenshotStartDate(date)
            }

            Button("한 달 전부터") {
                let date = Calendar.current.date(
                    byAdding: .month,
                    value: -1,
                    to: Date()
                ) ?? Date()

                saveScreenshotStartDate(date)
            }

            Button("취소", role: .cancel) {
                session.login()
            }
        }
    }

    private func requestPermissionsAfterSignUp() {
        NotificationPermissionManager.shared.requestInitialPermissionAfterSignUp { isNotificationAllowed in

            if isNotificationAllowed {
                LocalNotificationScheduler.shared.scheduleDailyCaptureCheckNotification()
            }

            PhotoPermissionManager.shared.requestPermission { isPhotoAllowed in

                if isPhotoAllowed {
                    showScreenshotStartDateDialog = true
                } else {
                    showsPermissionAlert = true
                }
            }
        }
    }

    private func saveScreenshotStartDate(_ date: Date) {
        UserDefaults.standard.set(
            date,
            forKey: screenshotStartDateKey
        )

        NotificationCenter.default.post(
            name: NSNotification.Name("ScreenshotDataUpdated"),
            object: nil
        )

        session.login()
    }
}

#Preview {
    SignUpView()
}

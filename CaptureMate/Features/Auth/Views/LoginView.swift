//
//  LoginView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

//
//  LoginView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var session: AppSession

    @StateObject private var viewModel = LoginViewModel()

    @State private var userId: String = ""
    @State private var password: String = ""
    @State private var isAutoLogin: Bool = false
    @State private var isSaveId: Bool = false

    @State private var showsPermissionAlert = false
    @State private var showScreenshotStartDateDialog = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 28)

                Text("로그인")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 20)

                VStack(spacing: 0) {
                    TextField("아이디", text: $userId)
                        .font(.system(size: 17))
                        .padding(.horizontal, 18)
                        .frame(height: 58)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Divider()
                        .padding(.leading, 18)

                    SecureField("비밀번호", text: $password)
                        .font(.system(size: 17))
                        .padding(.horizontal, 18)
                        .frame(height: 58)
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)

                Spacer().frame(height: 14)

                HStack(spacing: 16) {
                    ToggleChip(title: "자동 로그인", isOn: $isAutoLogin)
                    ToggleChip(title: "아이디 저장", isOn: $isSaveId)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)

                HStack(spacing: 0) {
                    Button("아이디 찾기") {
                    }

                    Text(" | ")
                        .foregroundColor(.secondary)

                    Button("비밀번호 찾기") {
                    }

                    Text(" | ")
                        .foregroundColor(.secondary)

                    NavigationLink {
                        SignUpView()
                    } label: {
                        Text("회원가입")
                    }
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

                Spacer().frame(height: 56)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
                
                Button {
                    viewModel.loginWithEmail(
                        userId: userId,
                        password: password
                    )
                } label: {
                    Text("로그인")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 50)

                VStack(spacing: 16) {
                    Text("간편 로그인")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)

                    SocialLoginButtonsView(viewModel: viewModel)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onChange(of: viewModel.isLoggedIn) { _, isLoggedIn in
            guard isLoggedIn else { return }
            handleLoginSuccess()
        }
        .alert("권한 허용이 필요해요", isPresented: $showsPermissionAlert) {
            Button("나중에") {
                InitialPermissionFlowManager.shared.markCompleted()
                session.login()
            }

            Button("설정으로 이동") {
                InitialPermissionFlowManager.shared.markCompleted()
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
                saveScreenshotStartDate(Calendar.current.startOfDay(for: Date()))
            }

            Button("3일 전부터") {
                let date = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
                saveScreenshotStartDate(date)
            }

            Button("일주일 전부터") {
                let date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                saveScreenshotStartDate(date)
            }

            Button("한 달 전부터") {
                let date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                saveScreenshotStartDate(date)
            }

            Button("취소", role: .cancel) {
                InitialPermissionFlowManager.shared.markCompleted()
                session.login()
            }
        }
    }

    private func handleLoginSuccess() {
        if InitialPermissionFlowManager.shared.hasCompletedInitialPermission {
            session.login()
        } else {
            requestInitialPermissions()
        }
    }

    private func requestInitialPermissions() {
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
        InitialPermissionFlowManager.shared.saveScreenshotStartDate(date)
        InitialPermissionFlowManager.shared.markCompleted()
        session.login()
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AppSession())
    }
}

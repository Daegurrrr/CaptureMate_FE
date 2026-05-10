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
    @State private var showsNotificationSettingsAlert = false
    
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
                LocalNotificationScheduler.shared.requestInitialPermissionAfterSignUp { isAllowed in
                    if isAllowed {
                        session.login()
                    } else {
                        showsNotificationSettingsAlert = true
                    }
                }
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
        .alert("알림 권한이 필요해요", isPresented: $showsNotificationSettingsAlert) {
            Button("나중에") {
                session.login()
            }

            Button("설정으로 이동") {
                session.login()
                LocalNotificationScheduler.shared.openAppNotificationSettings()
            }
        } message: {
            Text("매일 밤 10시에 새로운 캡쳐 확인 알림을 받으려면 설정에서 알림 권한을 허용해주세요.")
        }
    }
}

#Preview {
    SignUpView()
}

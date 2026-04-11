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

    @State private var userId: String = ""
    @State private var password: String = ""
    @State private var isAutoLogin: Bool = false
    @State private var isSaveId: Bool = false

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

                    Button("회원가입") {
                    }
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

                Spacer().frame(height: 56)

                Button {
                    session.login()
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

                    SocialLoginButtonsView()

                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AppSession())
    }
}

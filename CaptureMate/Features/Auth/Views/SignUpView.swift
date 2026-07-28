//
//  SignUpView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SignUpViewModel()

    @State private var loginId: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    private var isFormValid: Bool {
        !loginId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("회원가입")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 40)

            TextField("아이디", text: $loginId)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            TextField("이름", text: $username)
                .textFieldStyle(.roundedBorder)

            TextField("이메일", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            SecureField("비밀번호", text: $password)
                .textFieldStyle(.roundedBorder)
                .onChange(of: password) { _, newValue in
                    var result = ""

                    for char in newValue {
                        if (result + String(char)).utf8.count <= 72 {
                            result.append(char)
                        } else {
                            break
                        }
                    }
                    password = result
                }
            
            Text("비밀번호는 최대 72바이트까지 입력할 수 있어요.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }

            Button {
                viewModel.register(
                    loginId: loginId,
                    password: password,
                    username: username,
                    email: email
                )
            } label: {
                Text(viewModel.isLoading ? "가입 중..." : "회원가입 완료")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        isFormValid ? Color.blue : Color.gray.opacity(0.4)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(
                viewModel.isLoading || !isFormValid
            )
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 24)
        .onChange(of: viewModel.isRegisterSuccess) { _, isSuccess in
            if isSuccess {
                dismiss()
            }
        }
    }
}

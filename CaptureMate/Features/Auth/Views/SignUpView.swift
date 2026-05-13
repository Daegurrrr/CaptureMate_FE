//
//  SignUpView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

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
                dismiss()
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
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}

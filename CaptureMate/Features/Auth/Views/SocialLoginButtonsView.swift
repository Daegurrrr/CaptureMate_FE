//
//  Untitled.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

//
//  SocialLoginButtonsView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI
import AuthenticationServices

struct SocialLoginButtonsView: View {
    @ObservedObject var viewModel: LoginViewModel

    private let buttonHeight: CGFloat = 50
    private let cornerRadius: CGFloat = 30

    var body: some View {
        VStack(spacing: 12) {
            appleLoginButton

            googleLoginButton

            kakaoLoginButton

            naverLoginButton
        }
    }
    
    private var appleLoginButton: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                print("Apple onCompletion 호출됨")
                switch result {
                case .success(let authorization):
                    print("Apple 로그인 success")
                    handleAppleLoginSuccess(authorization)
                case .failure(let error):
                    print("Apple 로그인 실패:", error.localizedDescription)
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(maxWidth: .infinity)
        .frame(height: buttonHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var googleLoginButton: some View {
        Button {
            print("Google 로그인")
        } label: {
            HStack(spacing: 10) {
                Image("google_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)

                Text("Google로 로그인")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var kakaoLoginButton: some View {
        Button {
            print("Kakao 로그인")
        } label: {
            HStack(spacing: 10) {
                Image("kakao_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)

                Text("카카오로 로그인")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(Color(red: 254/255, green: 229/255, blue: 0/255))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
    }

    private var naverLoginButton: some View {
        Button {
            print("Naver 로그인")
        } label: {
            HStack(spacing: 10) {
                Image("naver_logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)

                Text("네이버로 로그인")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(Color(red: 3/255, green: 199/255, blue: 90/255))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
    }

    private func handleAppleLoginSuccess(_ authorization: ASAuthorization) {
        print("handleAppleLoginSuccess 진입")

        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Apple credential 변환 실패")
            return
        }

        print("credential 변환 성공")
        print("user:", credential.user)
        print("email:", credential.email ?? "email 없음")
        print("fullName:", credential.fullName?.description ?? "fullName 없음")

        guard let tokenData = credential.identityToken else {
            print("identityToken nil")
            return
        }

        print("identityToken data 있음")

        guard let identityToken = String(data: tokenData, encoding: .utf8) else {
            print("identityToken 문자열 변환 실패")
            return
        }

        print("Apple identityToken 추출 성공")
        print(identityToken)

        viewModel.loginWithApple(identityToken: identityToken)
    }
}

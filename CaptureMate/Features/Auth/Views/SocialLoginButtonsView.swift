//
//  Untitled.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI
import AuthenticationServices

struct SocialLoginButtonsView: View {
    let buttonHeight: CGFloat = 50
    let cornerRadius: CGFloat = 30

    var body: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    print("Apple login:", result)
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

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
    }
}

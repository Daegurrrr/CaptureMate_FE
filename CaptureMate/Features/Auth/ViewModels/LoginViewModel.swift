//
//  LoginViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/10/26.
//

import Foundation
import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authService = AuthService()

    func loginWithEmail(
        userId: String,
        password: String
    ) {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                let response = try await authService.login(
                    loginId: userId,
                    password: password
                )

                print("일반 로그인 성공:", response)

                saveLoginResponse(response)
                isLoggedIn = true

            } catch {
                print("일반 로그인 실패:", error.localizedDescription)
                errorMessage = convertLoginErrorMessage(error)
            }

            isLoading = false
        }
    }

    func loginWithApple(identityToken: String) {
        print("Apple identityToken:", identityToken)

        // Apple 백엔드 API 생기면 여기서 AuthService로 연결
        isLoggedIn = true
    }

    func loginWithGoogle() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            errorMessage = "Google 로그인을 실행할 화면을 찾을 수 없습니다."
            return
        }

        let config = GIDConfiguration(
            clientID: Secrets.value(for: "GOOGLE_CLIENT_ID")
        )

        GIDSignIn.sharedInstance.configuration = config

        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        ) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                print("Google Login Failed:", error.localizedDescription)
                self.errorMessage = self.convertLoginErrorMessage(error)
                self.isLoading = false
                return
            }

            guard let idToken = result?.user.idToken?.tokenString else {
                print("Google ID Token 없음")
                self.errorMessage = "Google 로그인 정보를 가져오지 못했습니다."
                self.isLoading = false
                return
            }

            print("Google ID Token:", idToken)

            Task {
                do {
                    let response = try await self.authService.googleLogin(
                        idToken: idToken
                    )

                    print("Backend Google Login Success:", response)

                    self.saveLoginResponse(response)
                    self.isLoggedIn = true

                } catch {
                    print("Backend Google Login Failed:", error.localizedDescription)
                    self.errorMessage = self.convertLoginErrorMessage(error)
                }

                self.isLoading = false
            }
        }
    }

    func loginWithKakao() {
        isLoading = true
        errorMessage = nil

        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                self?.handleKakaoLoginResult(
                    oauthToken: oauthToken,
                    error: error
                )
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                self?.handleKakaoLoginResult(
                    oauthToken: oauthToken,
                    error: error
                )
            }
        }
    }

    private func handleKakaoLoginResult(
        oauthToken: OAuthToken?,
        error: Error?
    ) {
        if let error = error {
            print("Kakao Login Failed:", error.localizedDescription)
            errorMessage = convertLoginErrorMessage(error)
            isLoading = false
            return
        }

        guard let accessToken = oauthToken?.accessToken else {
            errorMessage = "카카오 로그인 정보를 가져오지 못했습니다."
            isLoading = false
            return
        }

        print("Kakao AccessToken:", accessToken)

        Task {
            do {
                let response = try await authService.kakaoLogin(
                    accessToken: accessToken
                )

                print("Backend Kakao Login Success:", response)

                saveLoginResponse(response)
                isLoggedIn = true

            } catch {
                print("Backend Kakao Login Failed:", error.localizedDescription)
                errorMessage = convertLoginErrorMessage(error)
            }

            isLoading = false
        }
    }

    private func saveLoginResponse(_ response: LoginResponse) {
        if let accessToken = response.accessToken {
            UserDefaults.standard.set(accessToken, forKey: "accessToken")
        }

        if let refreshToken = response.refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
        }

        if let userId = response.userId {
            UserDefaults.standard.set(userId, forKey: "userId")
        }
    }

    private func convertLoginErrorMessage(_ error: Error) -> String {
        let message = error.localizedDescription

        if message.contains("Invalid") ||
            message.contains("invalid") ||
            message.contains("incorrect") ||
            message.contains("password") ||
            message.contains("credentials") ||
            message.contains("401") {
            return "아이디 또는 비밀번호가 올바르지 않습니다."
        }

        if message.contains("not found") ||
            message.contains("Not Found") ||
            message.contains("user") {
            return "가입되지 않은 계정입니다."
        }

        if message.contains("network") ||
            message.contains("timed out") ||
            message.contains("Internet") ||
            message.contains("offline") ||
            message.contains("서버에 연결할 수 없습니다") {
            return "네트워크 연결을 확인해주세요."
        }

        if message.contains("응답 데이터를 처리하지 못했습니다") {
            return "로그인 응답 처리 중 문제가 발생했습니다."
        }

        return message
    }
}

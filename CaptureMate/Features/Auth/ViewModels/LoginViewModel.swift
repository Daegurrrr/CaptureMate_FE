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

    func loginWithEmail(userId: String, password: String) {
        print("일반 로그인 시도:", userId)

        // TODO: 일반 로그인 API 연결 후 성공 시 true 처리
        isLoggedIn = true
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

        let config = GIDConfiguration(clientID: Secrets.value(for: "GOOGLE_CLIENT_ID"))
        
        GIDSignIn.sharedInstance.configuration = config
        
        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        ) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                print("Google Login Failed:", error.localizedDescription)
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }

            guard let idToken = result?.user.idToken?.tokenString else {
                print("Google ID Token 없음")
                self.errorMessage = "Google ID Token이 없습니다."
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
                    self.errorMessage = error.localizedDescription
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
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        }
    }

    private func handleKakaoLoginResult(
        oauthToken: OAuthToken?,
        error: Error?
    ) {
        if let error = error {
            print("Kakao Login Failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
            isLoading = false
            return
        }

        guard let accessToken = oauthToken?.accessToken else {
            errorMessage = "카카오 accessToken이 없습니다."
            isLoading = false
            return
        }

        print("Kakao AccessToken:", accessToken)

        Task {
            do {
                let response = try await authService.kakaoLogin(accessToken: accessToken)
                print("Backend Kakao Login Success:", response)

                saveLoginResponse(response)
                isLoggedIn = true
            } catch {
                print("Backend Kakao Login Failed:", error.localizedDescription)
                errorMessage = error.localizedDescription
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
}

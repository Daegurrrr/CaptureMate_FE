//
//  AuthService.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

final class AuthService {
    func register(
        loginId: String,
        password: String,
        username: String,
        email: String
    ) async throws {
        let body = RegisterRequest(
            loginId: loginId,
            password: password,
            username: username,
            email: email
        )

        let _: EmptyResponse = try await APIClient.shared.post(
            path: "/auth/register",
            body: body
        )
    }

    func login(
        loginId: String,
        password: String
    ) async throws -> LoginResponse {
        let body = LoginRequest(
            loginId: loginId,
            password: password
        )

        return try await APIClient.shared.post(
            path: "/auth/login",
            body: body
        )
    }

    func googleLogin(idToken: String) async throws -> LoginResponse {
        let body = GoogleLoginRequest(idToken: idToken)

        return try await APIClient.shared.post(
            path: "/auth/google",
            body: body
        )
    }

    func kakaoLogin(accessToken: String) async throws -> LoginResponse {
        let body = KakaoLoginRequest(accessToken: accessToken)

        return try await APIClient.shared.post(
            path: "/auth/kakao",
            body: body
        )
    }

    func logout() async throws {
        let _: EmptyResponse = try await APIClient.shared.post(
            path: "/auth/logout",
            body: EmptyRequest(),
            requiresAuth: true
        )
    }
}

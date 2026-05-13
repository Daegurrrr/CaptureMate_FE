//
//  AuthService.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

final class AuthService {
    private let baseURL = "http://172.20.10.5:8000"

    func googleLogin(idToken: String) async throws -> LoginResponse {
        let requestBody = GoogleLoginRequest(idToken: idToken)
        return try await post(
            path: "/auth/google",
            body: requestBody
        )
    }

    func kakaoLogin(accessToken: String) async throws -> LoginResponse {
        let requestBody = KakaoLoginRequest(accessToken: accessToken)
        return try await post(
            path: "/auth/kakao",
            body: requestBody
        )
    }
    
    func logout() async throws {
        guard let url = URL(string: baseURL + "/auth/logout") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Logout Status Code:", httpResponse.statusCode)
        }
    }

    private func post<T: Encodable>(
        path: String,
        body: T
    ) async throws -> LoginResponse {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code:", httpResponse.statusCode)
        }

        print("Response:", String(data: data, encoding: .utf8) ?? "")

        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
}

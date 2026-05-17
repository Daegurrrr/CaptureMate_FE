//
//  AuthService.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

struct APIErrorResponse: Decodable {
    let detail: String?
    let message: String?
}

enum AuthError: LocalizedError {
    case server(message: String, statusCode: Int)
    case invalidResponse
    case decodingFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .server(let message, _):
            return message
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다."
        case .decodingFailed:
            return "응답 데이터를 처리하지 못했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

struct EmptyResponse: Decodable {}

final class AuthService {
    private let baseURL = "http://192.168.219.101:8000"

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

        let _: EmptyResponse = try await post(
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

        return try await post(
            path: "/auth/login",
            body: body
        )
    }

    func googleLogin(idToken: String) async throws -> LoginResponse {
        let body = GoogleLoginRequest(idToken: idToken)

        return try await post(
            path: "/auth/google",
            body: body
        )
    }

    func kakaoLogin(accessToken: String) async throws -> LoginResponse {
        let body = KakaoLoginRequest(accessToken: accessToken)

        return try await post(
            path: "/auth/kakao",
            body: body
        )
    }

    func logout() async throws {
        guard let url = URL(string: baseURL + "/auth/logout") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue(
                "Bearer \(accessToken)",
                forHTTPHeaderField: "Authorization"
            )
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        print("Logout Status Code:", httpResponse.statusCode)

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = parseErrorMessage(from: data)

            throw AuthError.server(
                message: message,
                statusCode: httpResponse.statusCode
            )
        }
    }

    private func post<T: Encodable, R: Decodable>(
        path: String,
        body: T
    ) async throws -> R {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        print("Status Code:", httpResponse.statusCode)
        print("Response:", String(data: data, encoding: .utf8) ?? "")

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = parseErrorMessage(from: data)

            throw AuthError.server(
                message: message,
                statusCode: httpResponse.statusCode
            )
        }

        if R.self == EmptyResponse.self {
            return EmptyResponse() as! R
        }

        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            print("Decoding Failed:", error.localizedDescription)
            throw AuthError.decodingFailed
        }
    }

    private func parseErrorMessage(from data: Data) -> String {
        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            if let detail = errorResponse.detail, !detail.isEmpty {
                return detail
            }

            if let message = errorResponse.message, !message.isEmpty {
                return message
            }
        }

        if let plainText = String(data: data, encoding: .utf8),
           !plainText.isEmpty {
            return plainText
                .replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
                .replacingOccurrences(of: "detail:", with: "")
                .replacingOccurrences(of: "message:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return "요청 처리 중 오류가 발생했습니다."
    }
}

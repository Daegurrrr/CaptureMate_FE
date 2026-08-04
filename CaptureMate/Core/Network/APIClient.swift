//
//  APIClient.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation

final class APIClient {
    static let shared = APIClient()

    private init() {}

    func post<T: Encodable, R: Decodable>(
        path: String,
        body: T
    ) async throws -> R {
        guard let url = URL(string: APIConstants.baseURL + path) else {
            throw NetworkError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        return try handleResponse(
            data: data,
            response: response
        )
    }

    func uploadMultipart<R: Decodable>(
        path: String,
        multipart: MultipartFormData
    ) async throws -> R {
        guard let url = URL(string: APIConstants.baseURL + path) else {
            throw NetworkError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            multipart.contentType,
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = multipart.body

        let (data, response) = try await URLSession.shared.data(for: request)

        return try handleResponse(
            data: data,
            response: response
        )
    }

    private func handleResponse<R: Decodable>(
        data: Data,
        response: URLResponse
    ) throws -> R {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        print("Status Code:", httpResponse.statusCode)
        print("Response:", String(data: data, encoding: .utf8) ?? "")

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = parseErrorMessage(from: data)

            throw NetworkError.server(
                message: message,
                statusCode: httpResponse.statusCode
            )
        }

        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            print("Decoding Failed:", error)
            throw NetworkError.decodingFailed
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

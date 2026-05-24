//
//  NetworkError.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case server(message: String, statusCode: Int)
    case invalidResponse
    case decodingFailed
    case badURL

    var errorDescription: String? {
        switch self {
        case .server(let message, _):
            return message
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다."
        case .decodingFailed:
            return "응답 데이터를 처리하지 못했습니다."
        case .badURL:
            return "요청 주소가 올바르지 않습니다."
        }
    }
}

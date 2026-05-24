//
//  LoginResponse.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

struct LoginResponse: Decodable {
    let accessToken: String?
    let refreshToken: String?
    let tokenType: String?
    let userId: Int?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case userId = "user_id"
        case message
    }
}

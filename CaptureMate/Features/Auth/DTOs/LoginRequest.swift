//
//  LoginRequest.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

struct LoginRequest: Encodable {
    let loginId: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case loginId = "login_id"
        case password
    }
}

struct GoogleLoginRequest: Encodable {
    let idToken: String

    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
    }
}

struct KakaoLoginRequest: Encodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

struct RegisterRequest: Encodable {
    let loginId: String
    let password: String
    let username: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case loginId = "login_id"
        case password
        case username
        case email
    }
}

//
//  LoginRequest.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

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

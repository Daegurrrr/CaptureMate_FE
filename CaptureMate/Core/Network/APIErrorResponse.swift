//
//  APIErrorResponse.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

struct APIErrorResponse: Decodable {
    let detail: String?
    let message: String?
}

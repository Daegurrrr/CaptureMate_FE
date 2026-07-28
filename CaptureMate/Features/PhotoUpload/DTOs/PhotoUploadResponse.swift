//
//  PhotoUploadResponse.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation

struct PhotoUploadResponse: Decodable {
    let imageId: String?
    let category: String?
    let ocrText: String?
    let keywords: [String]?
    let actionType: String?
    let actionData: String?

    enum CodingKeys: String, CodingKey {
        case imageId = "image_id"
        case category
        case ocrText = "ocr_text"
        case keywords
        case actionType = "action_type"
        case actionData = "action_data"
    }
}

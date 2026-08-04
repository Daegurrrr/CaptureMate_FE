//
//  ClassifyResponse.swift
//  CaptureMate
//
//  Created by Codex on 8/4/26.
//

import Foundation

struct ClassifyResponse: Decodable {
    let localIdentifier: String
    let ocrText: String
    let category: String
    let confidence: Double
    let confidenceLevel: String

    enum CodingKeys: String, CodingKey {
        case localIdentifier = "local_identifier"
        case ocrText = "ocr_text"
        case category
        case confidence
        case confidenceLevel = "confidence_level"
    }
}

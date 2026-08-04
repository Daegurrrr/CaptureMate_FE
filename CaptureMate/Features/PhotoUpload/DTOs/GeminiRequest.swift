//
//  GeminiRequest.swift
//  CaptureMate
//
//  Created by Codex on 8/4/26.
//

import Foundation

struct GeminiRequest: Encodable {
    let localIdentifier: String
    let ocrText: String
    let category: String

    enum CodingKeys: String, CodingKey {
        case localIdentifier = "local_identifier"
        case ocrText = "ocr_text"
        case category
    }
}

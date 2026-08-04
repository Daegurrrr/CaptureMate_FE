//
//  OCRResponse.swift
//  CaptureMate
//
//  Created by Codex on 8/4/26.
//

import Foundation

struct OCRResponse: Decodable {
    let localIdentifier: String
    let ocrText: String

    enum CodingKeys: String, CodingKey {
        case localIdentifier = "local_identifier"
        case ocrText = "ocr_text"
    }
}

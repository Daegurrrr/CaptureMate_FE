//
//  GeminiResponse.swift
//  CaptureMate
//
//  Created by Codex on 8/4/26.
//

import Foundation

struct GeminiResponse: Decodable {
    let localIdentifier: String
    let category: String
    let result: GeminiAnalysisResult

    enum CodingKeys: String, CodingKey {
        case localIdentifier = "local_identifier"
        case category
        case result
    }
}

struct GeminiAnalysisResult: Decodable {
    let items: [ScreenshotSummaryItem]?
    let title: String?
    let content: String?
}

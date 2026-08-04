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

struct ScreenshotSummaryItem: Decodable {
    let placeName: String?
    let address: String?
    let mapUrl: String?

    let title: String?
    let startAt: String?
    let endAt: String?

    let productName: String?
    let shoppingUrl: String?

    let content: String?

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case address
        case mapUrl = "map_url"

        case title
        case startAt = "start_at"
        case endAt = "end_at"

        case productName = "product_name"
        case shoppingUrl = "shopping_url"

        case content
    }
}

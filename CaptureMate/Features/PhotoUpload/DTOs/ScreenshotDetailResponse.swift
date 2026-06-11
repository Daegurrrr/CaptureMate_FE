//
//  ScreenshotDetailResponse.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/25/26.
//

import Foundation

struct ScreenshotDetailResponse: Decodable {
    let success: Bool
    let data: ScreenshotDetailData
}

struct ScreenshotDetailData: Decodable {
    let screenshotId: Int
    let localIdentifier: String
    let ocrText: String?
    let status: String?
    let createdAt: String?
    let analysis: ScreenshotAnalysis?

    enum CodingKeys: String, CodingKey {
        case screenshotId = "screenshot_id"
        case localIdentifier = "local_identifier"
        case ocrText = "ocr_text"
        case status
        case createdAt = "created_at"
        case analysis
    }
}

struct ScreenshotAnalysis: Decodable {
    let analysisId: Int?
    let category: String
    let confidenceScore: Double?
    let analyzedAt: String?
    let items: [ScreenshotSummaryItem]?

    enum CodingKeys: String, CodingKey {
        case analysisId = "analysis_id"
        case category
        case confidenceScore = "confidence_score"
        case analyzedAt = "analyzed_at"
        case items
    }
}

struct ScreenshotSummary: Decodable {
    let items: [ScreenshotSummaryItem]
}

struct ScreenshotSummaryItem: Decodable {
    let placeId: Int?
    let placeName: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let mapUrl: String?

    let scheduleId: Int?
    let title: String?
    let startAt: String?
    let endAt: String?

    let shoppingId: Int?
    let productName: String?
    let shoppingUrl: String?

    let memoId: Int?
    let content: String?

    let isActionCompleted: Bool?

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case placeName = "place_name"
        case address
        case latitude
        case longitude
        case mapUrl = "map_url"

        case scheduleId = "schedule_id"
        case title
        case startAt = "start_at"
        case endAt = "end_at"

        case shoppingId = "shopping_id"
        case productName = "product_name"
        case shoppingUrl = "shopping_url"

        case memoId = "memo_id"
        case content

        case isActionCompleted = "is_action_completed"
    }
}

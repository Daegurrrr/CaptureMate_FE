//
//  PhotoUploadResponse.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation

struct PhotoUploadResponse: Decodable {
    let success: Bool
    let data: ScreenshotData
}

struct ScreenshotData: Decodable {
    let screenshotId: Int
    let localIdentifier: String
    let ocrText: String?
    let status: String
    let createdAt: String?
    let analysis: AnalysisData?

    enum CodingKeys: String, CodingKey {
        case screenshotId = "screenshot_id"
        case localIdentifier = "local_identifier"
        case ocrText = "ocr_text"
        case status
        case createdAt = "created_at"
        case analysis
    }
}

struct AnalysisData: Decodable {
    let analysisId: Int
    let category: String?
    let confidenceScore: Double?
    let analyzedAt: String?
    let items: [AnalysisItem]

    enum CodingKeys: String, CodingKey {
        case analysisId = "analysis_id"
        case category
        case confidenceScore = "confidence_score"
        case analyzedAt = "analyzed_at"
        case items
    }
}

struct AnalysisItem: Decodable, Encodable {
    let placeName: String?
    let address: String?
    let mapURL: String?

    let productName: String?
    let shoppingURL: String?

    let title: String?
    let startAt: String?
    let endAt: String?

    let content: String?

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case address
        case mapURL = "map_url"

        case productName = "product_name"
        case shoppingURL = "shopping_url"

        case title
        case startAt = "start_at"
        case endAt = "end_at"

        case content
    }
}

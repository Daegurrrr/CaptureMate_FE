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
    let analysis: ScreenshotAnalysis?

    enum CodingKeys: String, CodingKey {
        case screenshotId = "screenshot_id"
        case localIdentifier = "local_identifier"
        case ocrText = "ocr_text"
        case analysis
    }
}

struct ScreenshotAnalysis: Decodable {
    let category: String
    let summary: ScreenshotSummary

    enum CodingKeys: String, CodingKey {
        case category
        case summary
    }
}

struct ScreenshotSummary: Decodable {
    let items: [ScreenshotSummaryItem]
}

struct ScreenshotSummaryItem: Decodable {
    let placeName: String?
    let address: String?
    let title: String?
    let startAt: String?
    let endAt: String?

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case address
        case title
        case startAt = "start_at"
        case endAt = "end_at"
    }
}

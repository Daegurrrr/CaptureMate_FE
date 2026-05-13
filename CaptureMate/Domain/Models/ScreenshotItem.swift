//
//  ScreenshotItem.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import Foundation

struct ScreenshotItem: Identifiable, Hashable {
    let id: UUID
    let imageName: String
    let category: CaptureCategory
    let createdAt: Date
    let extractedText: String?
    let title: String?
    let summary: String?

    init(
        id: UUID = UUID(),
        imageName: String,
        category: CaptureCategory,
        createdAt: Date = Date(),
        extractedText: String? = nil,
        title: String? = nil,
        summary: String? = nil
    ) {
        self.id = id
        self.imageName = imageName
        self.category = category
        self.createdAt = createdAt
        self.extractedText = extractedText
        self.title = title
        self.summary = summary
    }
}

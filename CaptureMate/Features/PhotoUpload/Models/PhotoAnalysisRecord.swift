//
//  PhotoAnalysisRecord.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation
import SwiftData

@Model
final class PhotoAnalysisRecord {
    @Attribute(.unique) var localIdentifier: String
    var serverImageId: String?
    var category: String?
    var ocrText: String?
    var keywords: [String]
    var actionType: String?
    var actionData: String?
    var imageCreatedAt: Date?
    var analyzedAt: Date?

    init(localIdentifier: String) {
        self.localIdentifier = localIdentifier
        self.keywords = []
    }
}

//
//  PhotoUploadRecord.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation
import SwiftData

@Model
final class PhotoUploadRecord {
    @Attribute(.unique) var localIdentifier: String
    var uploadStatus: String
    var serverImageId: String?
    var retryCount: Int
    var createdAt: Date
    var uploadedAt: Date?

    init(localIdentifier: String) {
        self.localIdentifier = localIdentifier
        self.uploadStatus = "pending"
        self.serverImageId = nil
        self.retryCount = 0
        self.createdAt = Date()
        self.uploadedAt = nil
    }
}

//
//  PhotoUploadService.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation
import Photos
import SwiftData

@MainActor
final class PhotoUploadService {
    private let photoAssetService = PhotoAssetService()

    func uploadPhoto(
        imageData: Data,
        localIdentifier: String
    ) async throws -> PhotoUploadResponse {
        var multipart = MultipartFormData()

        multipart.appendFile(
            name: "file",
            filename: "screenshot.jpg",
            mimeType: "image/jpeg",
            data: imageData
        )

        multipart.appendText(
            name: "local_identifier",
            value: localIdentifier
        )

        multipart.finalize()

        return try await APIClient.shared.uploadMultipart(
            path: "/screenshots",
            multipart: multipart,
            requiresAuth: true
        )
    }

    func uploadNewPhotos(modelContext: ModelContext) async {
        let assets = photoAssetService.fetchScreenshotAssets()

        print("업로드 대상 캡처 이미지 개수:", assets.count)

        for asset in assets {
            let localId = asset.localIdentifier

            let descriptor = FetchDescriptor<PhotoUploadRecord>(
                predicate: #Predicate { $0.localIdentifier == localId }
            )

            let existing = try? modelContext.fetch(descriptor)

            if let existing, !existing.isEmpty {
                print("이미 업로드 기록 있음:", localId)
                continue
            }

            let record = PhotoUploadRecord(localIdentifier: localId)
            modelContext.insert(record)

            do {
                guard let imageData = await photoAssetService.getImageData(from: asset) else {
                    record.uploadStatus = "failed"
                    record.retryCount += 1
                    try? modelContext.save()
                    print("이미지 데이터 변환 실패:", localId)
                    continue
                }

                record.uploadStatus = "uploading"
                try? modelContext.save()

                let response = try await uploadPhoto(
                    imageData: imageData,
                    localIdentifier: localId
                )

                record.uploadStatus = "uploaded"
                record.serverImageId = response.imageId
                record.uploadedAt = Date()

                let analysis = PhotoAnalysisRecord(localIdentifier: localId)
                analysis.serverImageId = response.imageId
                analysis.category = response.category
                analysis.ocrText = response.ocrText
                analysis.keywords = response.keywords ?? []
                analysis.actionType = response.actionType
                analysis.actionData = response.actionData
                analysis.imageCreatedAt = asset.creationDate
                analysis.analyzedAt = Date()

                modelContext.insert(analysis)

                try modelContext.save()

                print("사진 업로드 성공:", localId)

            } catch {
                record.uploadStatus = "failed"
                record.retryCount += 1
                try? modelContext.save()

                print("사진 업로드 실패:", localId, error.localizedDescription)
            }
        }
    }
}

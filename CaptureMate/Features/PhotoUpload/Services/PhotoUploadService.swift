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
    
    func fetchScreenshotDetail(
        localIdentifier: String
    ) async throws -> ScreenshotDetailResponse {
        let encodedLocalId = localIdentifier.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? localIdentifier

        return try await APIClient.shared.get(
            path: "/screenshots/detail?local_identifier=\(encodedLocalId)",
            requiresAuth: true
        )
    }

    func uploadNewPhotos(modelContext: ModelContext) async {
        let startDate = InitialPermissionFlowManager.shared.screenshotStartDate
        let assets = photoAssetService.fetchScreenshotAssets(from: startDate)

        print("업로드 시작 기준 날짜:", startDate as Any)
        print("업로드 대상 캡처 이미지 개수:", assets.count)

        for asset in assets {
            let localId = asset.localIdentifier

            let descriptor = FetchDescriptor<PhotoUploadRecord>(
                predicate: #Predicate { $0.localIdentifier == localId }
            )

            let existing = try? modelContext.fetch(descriptor)
            let existingRecord = existing?.first

            if let existingRecord,
               existingRecord.uploadStatus == "uploaded" {
                print("이미 업로드 완료:", localId)
                continue
            }

            let record = existingRecord ?? PhotoUploadRecord(localIdentifier: localId)

            if existingRecord == nil {
                modelContext.insert(record)
            } else {
                print("기존 업로드 실패/대기 기록 있음, 재시도:", localId)
            }

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

                let uploadResponse = try await uploadPhoto(
                    imageData: imageData,
                    localIdentifier: localId
                )

                let detailResponse = try await fetchScreenshotDetail(
                    localIdentifier: localId
                )

                let detail = detailResponse.data

                record.uploadStatus = "uploaded"
                record.serverImageId = "\(detail.screenshotId)"
                record.uploadedAt = Date()

                let analysis = PhotoAnalysisRecord(localIdentifier: localId)
                analysis.serverImageId = "\(detail.screenshotId)"
                analysis.category = detail.analysis?.category
                analysis.ocrText = detail.ocrText
                analysis.imageCreatedAt = asset.creationDate
                analysis.analyzedAt = Date()

                if let items = detail.analysis?.summary.items {
                    analysis.actionData = makeSummaryText(from: items)
                }

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
    
    private func makeSummaryText(from items: [ScreenshotSummaryItem]) -> String {
        items.map { item in
            var parts: [String] = []

            if let placeName = item.placeName {
                parts.append("placeName: \(placeName)")
            }

            if let address = item.address {
                parts.append("address: \(address)")
            }

            if let title = item.title {
                parts.append("title: \(title)")
            }

            if let startAt = item.startAt {
                parts.append("startAt: \(startAt)")
            }

            if let endAt = item.endAt {
                parts.append("endAt: \(endAt)")
            }

            return parts.joined(separator: "\n")
        }
        .joined(separator: "\n\n")
    }
}

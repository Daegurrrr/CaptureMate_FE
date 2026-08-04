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

    func extractOCR(
        imageData: Data,
        localIdentifier: String
    ) async throws -> OCRResponse {
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
            path: "/ocr",
            multipart: multipart
        )
    }

    func classifyOCRText(
        localIdentifier: String,
        ocrText: String
    ) async throws -> ClassifyResponse {
        let request = ClassifyRequest(
            localIdentifier: localIdentifier,
            ocrText: ocrText
        )

        return try await APIClient.shared.post(
            path: "/classify",
            body: request
        )
    }

    func analyzeCategoryDetails(
        localIdentifier: String,
        ocrText: String,
        category: String
    ) async throws -> GeminiResponse {
        let request = GeminiRequest(
            localIdentifier: localIdentifier,
            ocrText: ocrText,
            category: category
        )

        return try await APIClient.shared.post(
            path: "/gemini",
            body: request
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
               existingRecord.uploadStatus == "analyzed" {
                print("이미 OCR/분류/상세분석 완료:", localId)
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

                let ocrResponse = try await extractOCR(
                    imageData: imageData,
                    localIdentifier: localId
                )

                record.uploadStatus = "ocr_completed"
                try? modelContext.save()

                let classifyResponse = try await classifyOCRText(
                    localIdentifier: ocrResponse.localIdentifier,
                    ocrText: ocrResponse.ocrText
                )

                record.uploadStatus = "classified"
                try? modelContext.save()

                let geminiResponse = try await analyzeCategoryDetails(
                    localIdentifier: classifyResponse.localIdentifier,
                    ocrText: classifyResponse.ocrText,
                    category: classifyResponse.category
                )

                record.uploadStatus = "analyzed"
                record.serverImageId = nil
                record.uploadedAt = Date()

                let analysisDescriptor = FetchDescriptor<PhotoAnalysisRecord>(
                    predicate: #Predicate { $0.localIdentifier == localId }
                )

                let existingAnalysis = try? modelContext.fetch(analysisDescriptor).first

                let analysis = existingAnalysis ?? PhotoAnalysisRecord(localIdentifier: localId)

                analysis.serverImageId = nil
                analysis.category = classifyResponse.category
                analysis.ocrText = ocrResponse.ocrText
                analysis.imageCreatedAt = asset.creationDate
                analysis.analyzedAt = Date()
                analysis.actionData = makeSummaryText(from: geminiResponse.result)

                if existingAnalysis == nil {
                    modelContext.insert(analysis)
                }

                try modelContext.save()

                verifySavedAnalysis(
                    localIdentifier: localId,
                    modelContext: modelContext
                )

                print(
                    "PaddleOCR/분류 결과 저장 성공:",
                    localId,
                    classifyResponse.category,
                    classifyResponse.confidence,
                    classifyResponse.confidenceLevel,
                    "actionDataLength:",
                    analysis.actionData?.count ?? 0
                )

            } catch {
                record.uploadStatus = "failed"
                record.retryCount += 1
                try? modelContext.save()

                print("사진 업로드 실패:", localId, error.localizedDescription)
            }
        }
    }

    private func verifySavedAnalysis(
        localIdentifier: String,
        modelContext: ModelContext
    ) {
        let descriptor = FetchDescriptor<PhotoAnalysisRecord>(
            predicate: #Predicate { $0.localIdentifier == localIdentifier }
        )

        guard let saved = try? modelContext.fetch(descriptor).first else {
            print("앱 DB 저장 확인 실패:", localIdentifier)
            return
        }

        print(
            "앱 DB 저장 확인:",
            saved.localIdentifier,
            "category:",
            saved.category ?? "nil",
            "ocrTextLength:",
            saved.ocrText?.count ?? 0
        )
    }

    private func makeSummaryText(from result: GeminiAnalysisResult) -> String? {
        if let items = result.items, !items.isEmpty {
            let summary = makeSummaryText(from: items)
            return summary.isEmpty ? nil : summary
        }

        var parts: [String] = []

        if let title = result.title, !title.isEmpty {
            parts.append(title)
        }

        if let content = result.content, !content.isEmpty {
            parts.append(content)
        }

        let summary = parts.joined(separator: "\n")
        return summary.isEmpty ? nil : summary
    }

    private func makeSummaryText(from items: [ScreenshotSummaryItem]) -> String {
        items.map { item in
            var parts: [String] = []

            if let placeName = item.placeName {
                parts.append(placeName)
            }

            if let address = item.address {
                parts.append(address)
            }

            if let title = item.title {
                parts.append(title)
            }

            if let startAt = item.startAt {
                parts.append(formatDate(startAt))
            }

            if let endAt = item.endAt {
                parts.append(formatDate(endAt))
            }

            if let productName = item.productName {
                parts.append(productName)
            }

            if let content = item.content {
                parts.append(content)
            }
            
            if let mapUrl = item.mapUrl {
                parts.append(mapUrl)
            }

            if let shoppingUrl = item.shoppingUrl {
                parts.append(shoppingUrl)
            }

            return parts.joined(separator: "\n")
        }
        .joined(separator: "\n\n")
    }
    
    private func formatDate(_ text: String) -> String {
        let formatter = ISO8601DateFormatter()

        guard let date = formatter.date(from: text) else {
            return text
        }

        let output = DateFormatter()
        output.dateFormat = "yyyy.MM.dd HH:mm"

        return output.string(from: date)
    }
}

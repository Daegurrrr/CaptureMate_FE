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

        var processedLocalIdentifiers = Set<String>()

        for asset in assets {
            let localId = asset.localIdentifier

            guard processedLocalIdentifiers.insert(localId).inserted else {
                print("이번 업로드 목록 내 중복 사진 건너뜀:", localId)
                continue
            }

            let descriptor = FetchDescriptor<PhotoUploadRecord>(
                predicate: #Predicate { $0.localIdentifier == localId }
            )

            let existing = try? modelContext.fetch(descriptor)
            let existingRecord = existing?.first

            let existingAnalysis = fetchAnalysisRecord(
                localIdentifier: localId,
                modelContext: modelContext
            )

            if isCompletedAnalysis(existingAnalysis) {
                if let existingRecord, existingRecord.uploadStatus != "analyzed" {
                    existingRecord.uploadStatus = "analyzed"
                    existingRecord.uploadedAt = existingAnalysis?.analyzedAt
                    try? modelContext.save()
                }

                print("이미 OCR/분류/상세분석 결과 저장 완료, API 호출 건너뜀:", localId)
                continue
            }

            if let existingRecord,
               existingRecord.uploadStatus == "analyzed" {
                print("분석 완료 상태지만 저장 결과가 없어 재분석:", localId)
            }

            let record = existingRecord ?? PhotoUploadRecord(localIdentifier: localId)

            if existingRecord == nil {
                modelContext.insert(record)
            } else {
                print("기존 업로드 기록 있음, 상태 기준으로 재시도:", localId, record.uploadStatus)
            }

            do {
                let analysis = existingAnalysis ?? PhotoAnalysisRecord(localIdentifier: localId)

                if existingAnalysis == nil {
                    modelContext.insert(analysis)
                }

                let ocrText: String
                let category: String
                var confidence: Double?
                var confidenceLevel: String?

                if record.uploadStatus == "classified",
                   let savedOCRText = analysis.ocrText,
                   !savedOCRText.isEmpty,
                   let savedCategory = analysis.category,
                   !savedCategory.isEmpty {
                    print("분류 완료 상태 확인, 상세분석부터 재시도:", localId)
                    ocrText = savedOCRText
                    category = savedCategory
                } else {
                    if record.uploadStatus == "ocr_completed",
                       let savedOCRText = analysis.ocrText,
                       !savedOCRText.isEmpty {
                        print("OCR 완료 상태 확인, 분류부터 재시도:", localId)
                        ocrText = savedOCRText
                    } else {
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

                        analysis.serverImageId = nil
                        analysis.ocrText = ocrResponse.ocrText
                        analysis.imageCreatedAt = asset.creationDate

                        record.uploadStatus = "ocr_completed"
                        try modelContext.save()

                        ocrText = ocrResponse.ocrText
                    }

                    let classifyResponse = try await classifyOCRText(
                        localIdentifier: localId,
                        ocrText: ocrText
                    )

                    analysis.category = classifyResponse.category
                    record.uploadStatus = "classified"
                    try modelContext.save()

                    category = classifyResponse.category
                    confidence = classifyResponse.confidence
                    confidenceLevel = classifyResponse.confidenceLevel
                }

                let geminiResponse = try await analyzeCategoryDetails(
                    localIdentifier: localId,
                    ocrText: ocrText,
                    category: category
                )

                record.uploadStatus = "analyzed"
                record.serverImageId = nil
                record.uploadedAt = Date()

                analysis.serverImageId = nil
                analysis.category = category
                analysis.ocrText = ocrText
                analysis.imageCreatedAt = asset.creationDate
                analysis.analyzedAt = Date()
                analysis.actionData = makeSummaryText(from: geminiResponse.result)

                try modelContext.save()

                verifySavedAnalysis(
                    localIdentifier: localId,
                    modelContext: modelContext
                )

                print(
                    "PaddleOCR/분류 결과 저장 성공:",
                    localId,
                    category,
                    confidence as Any,
                    confidenceLevel as Any,
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

    private func fetchAnalysisRecord(
        localIdentifier: String,
        modelContext: ModelContext
    ) -> PhotoAnalysisRecord? {
        let descriptor = FetchDescriptor<PhotoAnalysisRecord>(
            predicate: #Predicate { $0.localIdentifier == localIdentifier }
        )

        return try? modelContext.fetch(descriptor).first
    }

    private func isCompletedAnalysis(_ analysis: PhotoAnalysisRecord?) -> Bool {
        guard let analysis else {
            return false
        }

        return analysis.analyzedAt != nil
            && !(analysis.category?.isEmpty ?? true)
            && !(analysis.ocrText?.isEmpty ?? true)
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

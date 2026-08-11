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

    func classifyImage(
        imageData: Data,
        localIdentifier: String
    ) async throws -> ClassifyResponse {
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
            path: "/classify",
            multipart: multipart
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
                    guard let imageData = await photoAssetService.getImageData(from: asset) else {
                        record.uploadStatus = "failed"
                        record.retryCount += 1
                        try? modelContext.save()
                        print("이미지 데이터 변환 실패:", localId)
                        continue
                    }

                    record.uploadStatus = "uploading"
                    try? modelContext.save()

                    let classifyResponse = try await classifyImage(
                        imageData: imageData,
                        localIdentifier: localId
                    )

                    analysis.serverImageId = nil
                    analysis.ocrText = classifyResponse.ocrText
                    analysis.imageCreatedAt = asset.creationDate
                    analysis.category = classifyResponse.category

                    record.uploadStatus = "classified"
                    try modelContext.save()

                    ocrText = classifyResponse.ocrText
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
                analysis.actionData = makeSummaryText(
                    from: geminiResponse.result,
                    category: category
                )

                try modelContext.save()

                verifySavedAnalysis(
                    localIdentifier: localId,
                    modelContext: modelContext
                )

                print(
                    "분류/Gemini 분석 결과 저장 성공:",
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
            && !(analysis.actionData?.isEmpty ?? true)
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

    private func makeSummaryText(
        from result: GeminiAnalysisResult,
        category: String
    ) -> String? {
        if let items = result.items, !items.isEmpty {
            let summary = makeSummaryText(from: items, category: category)
            return summary.isEmpty ? nil : summary
        }

        var parts: [String] = []

        if let title = result.title, !title.isEmpty {
            parts.append("제목: \(title)")
        }

        if let content = result.content, !content.isEmpty {
            parts.append("내용: \(content)")
        }

        parts.append(contentsOf: makeAdditionalSummaryText(from: result.additionalFields))

        let summary = parts.joined(separator: "\n")
        return summary.isEmpty ? nil : summary
    }

    private func makeSummaryText(
        from items: [ScreenshotSummaryItem],
        category: String
    ) -> String {
        let normalizedCategory = normalizedCategory(category)

        return items.map { item in
            var parts: [String] = []

            switch normalizedCategory {
            case "장소":
                if let placeName = item.placeName {
                    parts.append("장소명: \(placeName)")
                }

                if let address = item.address {
                    parts.append("주소: \(address)")
                }

                if let latitude = item.latitude,
                   let longitude = item.longitude {
                    parts.append("좌표: \(latitude), \(longitude)")
                }

                if let mapProvider = item.mapProvider {
                    parts.append("지도 제공: \(mapProvider)")
                }

                if let mapUrl = item.mapUrl {
                    parts.append("지도 링크: \(mapUrl)")
                }

                parts.append(contentsOf: makeAdditionalSummaryText(from: item.additionalFields))

            case "쇼핑":
                if let productName = item.productName {
                    parts.append("상품명: \(productName)")
                }

                if let shoppingUrl = item.shoppingUrl {
                    parts.append("쇼핑 링크: \(shoppingUrl)")
                }

                if let brandSearchUrl = item.brandSearchUrl {
                    parts.append("브랜드 링크: \(brandSearchUrl)")
                }

                parts.append(contentsOf: makeAdditionalSummaryText(from: item.additionalFields))

            case "일정":
                if let title = item.title {
                    parts.append("일정명: \(title)")
                }

                if let startAt = item.startAt {
                    parts.append("시작: \(formatDate(startAt))")
                }

                if let endAt = item.endAt {
                    parts.append("종료: \(formatDate(endAt))")
                }

                parts.append(contentsOf: makeAdditionalSummaryText(from: item.additionalFields))

            default:
                if let title = item.title {
                    parts.append("제목: \(title)")
                }

                if let content = item.content {
                    parts.append("내용: \(content)")
                }

                parts.append(contentsOf: makeAdditionalSummaryText(from: item.additionalFields))
            }

            return parts.joined(separator: "\n")
        }
        .joined(separator: "\n\n")
    }

    private func makeAdditionalSummaryText(
        from fields: [String: JSONValue]
    ) -> [String] {
        let hiddenKeys: Set<String> = [
            "corrected_place_name",
            "map_query",
            "brand_name",
            "search_query"
        ]

        return fields
            .filter { !hiddenKeys.contains($0.key) }
            .sorted { $0.key < $1.key }
            .compactMap { key, value in
                guard let displayText = value.displayText else {
                    return nil
                }

                return "\(displayName(for: key)): \(displayText)"
            }
    }

    private func displayName(for key: String) -> String {
        switch key {
        case "place_name":
            return "장소명"
        case "address":
            return "주소"
        case "latitude":
            return "위도"
        case "longitude":
            return "경도"
        case "map_url":
            return "지도 링크"
        case "map_provider":
            return "지도 제공"
        case "product_name":
            return "상품명"
        case "shopping_url":
            return "쇼핑 링크"
        case "brand_search_url":
            return "브랜드 링크"
        case "title":
            return "제목"
        case "content":
            return "내용"
        case "start_at":
            return "시작"
        case "end_at":
            return "종료"
        default:
            return key
                .replacingOccurrences(of: "_", with: " ")
        }
    }

    private func normalizedCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "place":
            return "장소"
        case "shopping":
            return "쇼핑"
        case "schedule":
            return "일정"
        case "memo":
            return "메모"
        case "unknown":
            return "기타"
        default:
            return category
        }
    }
    
    private func formatDate(_ text: String) -> String {
        let formatter = ISO8601DateFormatter()

        if let date = formatter.date(from: text) {
            return displayDate(from: date)
        }

        let simpleISOFormatter = DateFormatter()
        simpleISOFormatter.locale = Locale(identifier: "ko_KR")
        simpleISOFormatter.timeZone = TimeZone.current
        simpleISOFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let date = simpleISOFormatter.date(from: text) {
            return displayDate(from: date)
        }

        return text
    }

    private func displayDate(from date: Date) -> String {
        let output = DateFormatter()
        output.locale = Locale(identifier: "ko_KR")
        output.timeZone = TimeZone.current
        output.dateFormat = "yyyy.MM.dd HH:mm"

        return output.string(from: date)
    }
}

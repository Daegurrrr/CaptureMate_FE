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
    ) async throws {
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

        return try await APIClient.shared.uploadMultipartWithoutDecoding(
            path: "/screenshots",
            multipart: multipart,
            requiresAuth: false
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
            requiresAuth: false
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

                let analysisDescriptor = FetchDescriptor<PhotoAnalysisRecord>(
                    predicate: #Predicate { $0.localIdentifier == localId }
                )

                let existingAnalysis = try? modelContext.fetch(analysisDescriptor).first

                // 이미 분석 결과까지 저장되어 있으면 완전히 건너뜀
                if existingAnalysis != nil {
                    print("이미 업로드 및 분석 완료:", localId)
                    continue
                }

                print("업로드 완료 상태지만 분석 정보 없음. 상세조회만 수행:", localId)

                do {
                    let detailResponse = try await fetchScreenshotDetail(
                        localIdentifier: localId
                    )

                    let detail = detailResponse.data
                    
                    existingRecord.serverImageId = "\(detail.screenshotId)"

                    let analysis = PhotoAnalysisRecord(
                        localIdentifier: localId
                    )

                    analysis.serverImageId = "\(detail.screenshotId)"
                    analysis.category = detail.analysis?.category
                    analysis.ocrText = detail.ocrText
                    analysis.imageCreatedAt = asset.creationDate

                    if let analyzedAtString = detail.analysis?.analyzedAt {
                        analysis.analyzedAt = ISO8601DateFormatter().date(
                            from: analyzedAtString
                        )
                    }

                    if let items = detail.analysis?.items {
                        analysis.actionData = makeSummaryText(from: items)
                    } else {
                        analysis.actionData = nil
                    }

                    modelContext.insert(analysis)
                    try? modelContext.save()

                    print("상세조회 재시도 성공:", localId)

                } catch {
                    print("상세조회 재시도 실패:", localId, error.localizedDescription)
                }

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
                    continue
                }

                record.uploadStatus = "uploading"
                try? modelContext.save()

                // ===== 업로드 =====
                try await uploadPhoto(
                    imageData: imageData,
                    localIdentifier: localId
                )

                // 업로드만 성공하면 성공 처리
                record.uploadStatus = "uploaded"
                record.uploadedAt = Date()
                try? modelContext.save()

                print("사진 업로드 성공:", localId)

            } catch {
                // 업로드 실패한 경우만 재시도
                record.uploadStatus = "failed"
                record.retryCount += 1
                try? modelContext.save()

                print("사진 업로드 실패:", localId, error.localizedDescription)
                continue
            }
            
            do {
                let detailResponse = try await fetchScreenshotDetail(
                    localIdentifier: localId
                )

                let detail = detailResponse.data

                record.serverImageId = "\(detail.screenshotId)"

                let analysisDescriptor = FetchDescriptor<PhotoAnalysisRecord>(
                    predicate: #Predicate { $0.localIdentifier == localId }
                )

                let existingAnalysis = try? modelContext.fetch(analysisDescriptor).first

                let analysis = existingAnalysis ?? PhotoAnalysisRecord(
                    localIdentifier: localId
                )

                analysis.serverImageId = "\(detail.screenshotId)"
                analysis.category = detail.analysis?.category
                analysis.ocrText = detail.ocrText
                analysis.imageCreatedAt = asset.creationDate

                if let analyzedAtString = detail.analysis?.analyzedAt {
                    analysis.analyzedAt = ISO8601DateFormatter().date(
                        from: analyzedAtString
                    )
                }

                if let items = detail.analysis?.items {
                    analysis.actionData = makeSummaryText(from: items)
                } else {
                    analysis.actionData = nil
                }

                if existingAnalysis == nil {
                    modelContext.insert(analysis)
                }

                try? modelContext.save()

                print("상세조회 및 분석 저장 성공:", localId)

            } catch {
                // 업로드는 성공했으므로 상태 변경 안 함
                print("상세조회 실패:", localId, error.localizedDescription)
            }
        }
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
            
            if let latitude = item.latitude {
                parts.append("latitude:\(latitude)")
            }

            if let longitude = item.longitude {
                parts.append("longitude:\(longitude)")
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
        output.locale = Locale(identifier: "ko_KR")

        // 시간이 00:00:00 또는 23:59:59이면 날짜만 표시
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)

        if (components.hour == 0 && components.minute == 0 && components.second == 0) ||
           (components.hour == 23 && components.minute == 59 && components.second == 59) {

            output.dateFormat = "yyyy.MM.dd"
        } else {
            output.dateFormat = "yyyy.MM.dd HH:mm"
        }

        return output.string(from: date)
    }
}

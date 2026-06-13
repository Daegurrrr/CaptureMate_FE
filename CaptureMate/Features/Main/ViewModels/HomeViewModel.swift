//
//  HomeViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/8/26.
//

import SwiftUI
import Photos
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayScreenshotCount: Int = 0
    @Published var placeCount = 0
    @Published var shoppingCount = 0
    @Published var scheduleCount = 0
    @Published var memoCount = 0
    @Published var recommendedActions: [RecommendedAction] = []
    private var pendingOpenedActionLocalIdentifier: String?
    
    func loadTodayScreenshotCount() {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        guard let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate < %@ AND (mediaSubtype & %d) != 0",
            startOfToday as NSDate,
            endOfToday as NSDate,
            PHAssetMediaSubtype.photoScreenshot.rawValue
        )
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        todayScreenshotCount = assets.count
    }
    
    func loadCategoryCounts(
        modelContext: ModelContext
    ) {

        do {

            let records =
                try modelContext.fetch(
                    FetchDescriptor<PhotoAnalysisRecord>()
                )

            placeCount =
                records.filter {
                    $0.category == "장소"
                }.count

            shoppingCount =
                records.filter {
                    $0.category == "쇼핑"
                }.count

            scheduleCount =
                records.filter {
                    $0.category == "일정"
                }.count

            memoCount =
                records.filter {
                    $0.category == "메모"
                }.count

        } catch {

            print(
                "카테고리 카운트 실패:",
                error.localizedDescription
            )
        }
    }
    
    func loadRecommendedActions(modelContext: ModelContext) {
        do {
            let records = try modelContext.fetch(FetchDescriptor<PhotoAnalysisRecord>())
            
            recommendedActions = records
                .filter { !$0.isActionCompleted }
                .compactMap { record -> RecommendedAction? in
                    guard let category = record.category else { return nil }

                    let lines = (record.actionData ?? "")
                        .split(separator: "\n")
                        .map { String($0) }

                    switch category {
                    case "장소":
                        let title = lines.first ?? "감지된 장소"
                        let url = lines.first { $0.contains("http") }

                        return RecommendedAction(
                            localIdentifier: record.localIdentifier,
                            icon: "mappin.and.ellipse",
                            title: title,
                            subtitle: "장소 바로가기",
                            type: .place,
                            url: url,
                            startDate: nil,
                            endDate: nil
                        )

                    case "쇼핑":
                        let title = lines.first ?? "감지된 상품"
                        let url = lines.first { $0.contains("http") }

                        return RecommendedAction(
                            localIdentifier: record.localIdentifier,
                            icon: "bag",
                            title: title,
                            subtitle: "상품 보러가기",
                            type: .shopping,
                            url: url,
                            startDate: nil,
                            endDate: nil
                        )

                    case "일정":
                        let title = lines.first ?? "감지된 일정"

                        let startDate = lines
                            .compactMap { parseDate(from: $0) }
                            .first

                        let endDate = startDate.flatMap {
                            Calendar.current.date(
                                byAdding: .hour,
                                value: 1,
                                to: $0
                            )
                        }

                        return RecommendedAction(
                            localIdentifier: record.localIdentifier,
                            icon: "calendar",
                            title: title,
                            subtitle: "캘린더에 추가하기",
                            type: .schedule,
                            url: nil,
                            startDate: startDate,
                            endDate: endDate
                        )

                    default:
                        return nil
                    }
                }
            
        } catch {
            print("추천 액션 로드 실패:", error.localizedDescription)
        }
    }
    
    private func parseDate(from text: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = isoFormatter.date(from: text) {
            return date
        }

        let simpleISOFormatter = DateFormatter()
        simpleISOFormatter.locale = Locale(identifier: "ko_KR")
        simpleISOFormatter.timeZone = TimeZone.current
        simpleISOFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let date = simpleISOFormatter.date(from: text) {
            return date
        }

        let dateOnlyFormatter = DateFormatter()
        dateOnlyFormatter.locale = Locale(identifier: "ko_KR")
        dateOnlyFormatter.timeZone = TimeZone.current
        dateOnlyFormatter.dateFormat = "yyyy-MM-dd"

        return dateOnlyFormatter.date(from: text)
    }
    
    func removeAction(
        _ action: RecommendedAction,
        modelContext: ModelContext
    ) {
        let localId = action.localIdentifier

        let descriptor = FetchDescriptor<PhotoAnalysisRecord>(
            predicate: #Predicate { $0.localIdentifier == localId }
        )

        do {
            if let record = try modelContext.fetch(descriptor).first {
                record.isActionCompleted = true
                try modelContext.save()
            }

            recommendedActions.removeAll {
                $0.id == action.id
            }

        } catch {
            print("추천액션 삭제 저장 실패:", error.localizedDescription)
        }
    }
    
    func markActionAsPendingOpened(_ action: RecommendedAction) {
        pendingOpenedActionLocalIdentifier = action.localIdentifier
    }

    func completePendingOpenedActionIfNeeded(modelContext: ModelContext) {
        guard let localIdentifier = pendingOpenedActionLocalIdentifier else {
            return
        }

        let descriptor = FetchDescriptor<PhotoAnalysisRecord>(
            predicate: #Predicate { $0.localIdentifier == localIdentifier }
        )

        do {
            if let record = try modelContext.fetch(descriptor).first {
                record.isActionCompleted = true
                try modelContext.save()
            }

            recommendedActions.removeAll {
                $0.localIdentifier == localIdentifier
            }

            pendingOpenedActionLocalIdentifier = nil

        } catch {
            print("추천 액션 자동 완료 처리 실패:", error.localizedDescription)
        }
    }
}

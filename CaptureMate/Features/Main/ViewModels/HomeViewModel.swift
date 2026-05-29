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
    @Published var recommendedActions: [RecommendedAction] = []

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

    func loadRecommendedActions(modelContext: ModelContext) {
        do {
            let records = try modelContext.fetch(FetchDescriptor<PhotoAnalysisRecord>())

            recommendedActions = records.compactMap { record -> RecommendedAction? in
                guard let category = record.category else { return nil }

                let lines = (record.actionData ?? "")
                    .split(separator: "\n")
                    .map { String($0) }

                switch category {
                case "장소":
                    let title = lines.first ?? "감지된 장소"
                    let url = lines.first { $0.contains("http") }
                    return RecommendedAction(
                        icon: "mappin.and.ellipse",
                        title: title,
                        subtitle: "장소 바로가기",
                        type: .place,
                        url: url,
                        dateText: nil
                    )

                case "쇼핑":
                    let title = lines.first ?? "감지된 상품"
                    let url = lines.first { $0.contains("http") }
                    return RecommendedAction(
                        icon: "bag",
                        title: title,
                        subtitle: "상품 보러가기",
                        type: .shopping,
                        url: url,
                        dateText: nil
                    )

                case "일정":
                    let title = lines.first ?? "감지된 일정"
                    let dateText = lines.dropFirst().first
                    return RecommendedAction(
                        icon: "calendar",
                        title: title,
                        subtitle: "캘린더에 추가하기",
                        type: .schedule,
                        url: nil,
                        dateText: dateText
                    )

                default:
                    return nil
                }
            }

        } catch {
            print("추천 액션 로드 실패:", error.localizedDescription)
        }
    }
}

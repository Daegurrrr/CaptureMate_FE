//
//  HomeViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/8/26.
//

import SwiftUI
import Photos

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayScreenshotCount: Int = 0

    private let screenshotStartDateKey = "screenshotStartDate"

    func loadTodayScreenshotCount() {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        guard let endOfToday = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfToday
        ) else {
            return
        }

        let fetchOptions = PHFetchOptions()

        fetchOptions.predicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate < %@ AND (mediaSubtype & %d) != 0",
            startOfToday as NSDate,
            endOfToday as NSDate,
            PHAssetMediaSubtype.photoScreenshot.rawValue
        )
        
        let assets = PHAsset.fetchAssets(
            with: .image,
            options: fetchOptions
        )

        todayScreenshotCount = assets.count
    }
}

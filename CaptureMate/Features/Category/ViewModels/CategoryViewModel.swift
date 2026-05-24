//
//  CategoryViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation
import Photos
import SwiftUI
import SwiftData

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var photos: [CategoryPhotoItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: CaptureCategory = .schedule

    var filteredItems: [CategoryPhotoItem] {
        photos.filter { item in
            let selectedCategoryText = categoryText(selectedCategory)

            let matchesCategory = item.category == selectedCategoryText

            let matchesSearch =
                searchText.isEmpty ||
                item.category.localizedCaseInsensitiveContains(searchText)

            return matchesCategory && matchesSearch
        }
    }

    func requestPhotoPermissionAndLoad(modelContext: ModelContext) {
        PhotoPermissionManager.shared.requestPermission { [weak self] isAllowed in
            guard let self else { return }

            guard isAllowed else {
                print("사진 권한 없음")
                return
            }

            Task { @MainActor in
                self.loadPhotos(modelContext: modelContext)
            }
        }
    }

    private func loadPhotos(modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<PhotoAnalysisRecord>()
            let records = try modelContext.fetch(descriptor)

            let categoryMap = Dictionary(
                uniqueKeysWithValues: records.map {
                    ($0.localIdentifier, $0.category ?? "미분류")
                }
            )

            let assets = PhotoAssetService().fetchScreenshotAssets(
                from: InitialPermissionFlowManager.shared.screenshotStartDate
            )

            Task {
                var loadedItems: [CategoryPhotoItem] = []

                for asset in assets {
                    guard let image = await PhotoAssetService().getUIImage(from: asset) else {
                        continue
                    }

                    let item = CategoryPhotoItem(
                        id: asset.localIdentifier,
                        image: image,
                        category: categoryMap[asset.localIdentifier] ?? "미분류"
                    )

                    loadedItems.append(item)
                }

                self.photos = loadedItems
            }

        } catch {
            print("카테고리 데이터 로드 실패:", error.localizedDescription)
        }
    }

    private func categoryText(_ category: CaptureCategory) -> String {
        switch category {
        case .shopping:
            return "쇼핑"
        case .place:
            return "장소"
        case .schedule:
            return "일정"
        case .memo:
            return "메모"
        case .unknown:
            return "기타"
        }
    }
}

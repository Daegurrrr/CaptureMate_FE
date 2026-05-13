//
//  CategoryViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

// 분류 모델 돌린 후는 지우기
import SwiftUI
import Photos

final class CategoryViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedCategory: CaptureCategory = .schedule
    
    //******** 실제 분류 모델 돌리고 나서는 사용하지 않을 부분(테스트용) ********//
    @Published var photos: [CategoryPhotoItem] = []
    
    func requestPhotoPermissionAndLoad() {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized || status == .limited {
                    self.loadScreenshots()
                }
            }
        }
    
    private func loadScreenshots() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let screenshotAlbum = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumScreenshots,
            options: nil
        )

        guard let collection = screenshotAlbum.firstObject else {
            return
        }

        let screenshots = PHAsset.fetchAssets(
            in: collection,
            options: fetchOptions
        )

        let imageManager = PHImageManager.default()

        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .fast

        var loadedPhotos: [CategoryPhotoItem] = []

        screenshots.enumerateObjects { asset, _, _ in
            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, _ in
                if let image = image {
                    let photoItem = CategoryPhotoItem(image: image)

                    DispatchQueue.main.async {
                        loadedPhotos.append(photoItem)
                        self.photos = loadedPhotos
                    }
                }
            }
        }
    }
    
    @Published var captureItems: [CategoryCaptureItem] = [
        CategoryCaptureItem(imageName: "sample_capture_1", category: .schedule),
        CategoryCaptureItem(imageName: "sample_capture_2", category: .schedule),
        CategoryCaptureItem(imageName: "sample_capture_3", category: .place),
        CategoryCaptureItem(imageName: "sample_capture_4", category: .shopping),
        CategoryCaptureItem(imageName: "sample_capture_5", category: .memo),
        CategoryCaptureItem(imageName: "sample_capture_6", category: .unknown)
    ]

    var filteredItems: [CategoryCaptureItem] {
        captureItems.filter {
            $0.category == selectedCategory
        }
    }
}

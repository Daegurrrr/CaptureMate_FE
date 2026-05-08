//
//  AddViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/8/26.
//

import SwiftUI
import Photos

@MainActor
final class AddViewModel: ObservableObject {
    @Published var newScreenshots: [ScreenshotPhoto] = []
    @Published var allScreenshots: [ScreenshotPhoto] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false

    private let lastCheckedDateKey = "lastCheckedScreenshotDate"

    func requestPhotoPermissionAndLoad() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            Task { @MainActor in
                self?.authorizationStatus = status

                if status == .authorized || status == .limited {
                    self?.fetchScreenshots()
                }
            }
        }
    }

    func fetchScreenshots() {
        isLoading = true

        let lastCheckedDate = UserDefaults.standard.object(
            forKey: lastCheckedDateKey
        ) as? Date

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var newAssets: [PHAsset] = []
        var existingAssets: [PHAsset] = []

        assets.enumerateObjects { asset, _, _ in
            guard asset.mediaSubtypes.contains(.photoScreenshot) else {
                return
            }

            if let lastCheckedDate,
               let creationDate = asset.creationDate,
               creationDate > lastCheckedDate {
                newAssets.append(asset)
            } else {
                existingAssets.append(asset)
            }
        }

        loadImages(newAssets: newAssets, existingAssets: existingAssets, isFirstLoad: lastCheckedDate == nil)
    }

    private func loadImages(
        newAssets: [PHAsset],
        existingAssets: [PHAsset],
        isFirstLoad: Bool
    ) {
        let imageManager = PHCachingImageManager()
        let targetSize = CGSize(width: 400, height: 400)

        var loadedNewPhotos: [ScreenshotPhoto] = []
        var loadedExistingPhotos: [ScreenshotPhoto] = []

        let group = DispatchGroup()

        for asset in newAssets {
            group.enter()

            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: nil
            ) { image, _ in
                if let image {
                    loadedNewPhotos.append(
                        ScreenshotPhoto(
                            id: asset.localIdentifier,
                            asset: asset,
                            image: image
                        )
                    )
                }
                group.leave()
            }
        }

        for asset in existingAssets {
            group.enter()

            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: nil
            ) { image, _ in
                if let image {
                    loadedExistingPhotos.append(
                        ScreenshotPhoto(
                            id: asset.localIdentifier,
                            asset: asset,
                            image: image
                        )
                    )
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if isFirstLoad {
                self.newScreenshots = []
                self.allScreenshots = loadedNewPhotos + loadedExistingPhotos
            } else {
                self.newScreenshots = loadedNewPhotos
                self.allScreenshots = loadedNewPhotos + loadedExistingPhotos
            }

            self.isLoading = false
            UserDefaults.standard.set(Date(), forKey: self.lastCheckedDateKey)
        }
    }
}

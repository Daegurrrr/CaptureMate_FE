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
    @Published var recentScreenshots: [UIImage] = []

    func loadRecentScreenshots() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            guard status == .authorized || status == .limited else { return }

            let options = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]

            let assets = PHAsset.fetchAssets(with: .image, options: options)

            var screenshotAssets: [PHAsset] = []

            assets.enumerateObjects { asset, _, stop in
                if asset.mediaSubtypes.contains(.photoScreenshot) {
                    screenshotAssets.append(asset)
                }

                if screenshotAssets.count == 5 {
                    stop.pointee = true
                }
            }

            self.loadImages(from: screenshotAssets)
        }
    }

    private func loadImages(from assets: [PHAsset]) {
        let imageManager = PHCachingImageManager()
        let targetSize = CGSize(width: 300, height: 300)

        var images: [UIImage] = []
        let group = DispatchGroup()

        for asset in assets {
            group.enter()

            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: nil
            ) { image, _ in
                if let image {
                    images.append(image)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.recentScreenshots = images
        }
    }
}

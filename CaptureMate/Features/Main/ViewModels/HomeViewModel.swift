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

    private let screenshotStartDateKey = "screenshotStartDate"

    func loadRecentScreenshots() {
        guard let startDate = UserDefaults.standard.object(
            forKey: screenshotStartDateKey
        ) as? Date else {
            recentScreenshots = []
            return
        }

        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        guard currentStatus == .authorized || currentStatus == .limited else {
            recentScreenshots = []
            return
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        // =====================================================
        // MARK: 시뮬레이터용
        // =====================================================
//        options.predicate = NSPredicate(
//            format: "creationDate >= %@",
//            startDate as NSDate
//        )

        // =====================================================
        // MARK: 실제 아이폰용
        // =====================================================
         options.predicate = NSPredicate(
             format: "creationDate >= %@ AND (mediaSubtype & %d) != 0",
             startDate as NSDate,
             PHAssetMediaSubtype.photoScreenshot.rawValue
         )

        options.fetchLimit = 50

        let assets = PHAsset.fetchAssets(with: .image, options: options)

        var screenshotAssets: [PHAsset] = []

        assets.enumerateObjects { asset, _, stop in
            // =====================================================
            // MARK: 시뮬레이터용
            // =====================================================
//            screenshotAssets.append(asset)

            // =====================================================
            // MARK: 실제 아이폰용
            // =====================================================
             if asset.mediaSubtypes.contains(.photoScreenshot) {
                 screenshotAssets.append(asset)
             }

            if screenshotAssets.count == 5 {
                stop.pointee = true
            }
        }

        loadImages(from: screenshotAssets)
    }

    private func loadImages(from assets: [PHAsset]) {
        let imageManager = PHCachingImageManager()
        let targetSize = CGSize(width: 300, height: 300)

        var images: [UIImage] = []
        let group = DispatchGroup()

        func appendImage(_ image: UIImage) {
            images.append(image)
        }

        func loadImage(from asset: PHAsset) {
            group.enter()

            let dataOptions = PHImageRequestOptions()
            dataOptions.isSynchronous = false
            dataOptions.deliveryMode = .highQualityFormat
            dataOptions.resizeMode = .none
            dataOptions.isNetworkAccessAllowed = true

            imageManager.requestImageDataAndOrientation(
                for: asset,
                options: dataOptions
            ) { data, _, _, _ in

                if let data,
                   let image = UIImage(data: data) {
                    appendImage(image)
                    group.leave()
                    return
                }

                let thumbOptions = PHImageRequestOptions()
                thumbOptions.isSynchronous = false
                thumbOptions.deliveryMode = .opportunistic
                thumbOptions.resizeMode = .fast
                thumbOptions.isNetworkAccessAllowed = true

                imageManager.requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: thumbOptions
                ) { image, info in
                    let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false

                    if isDegraded {
                        return
                    }

                    if let image {
                        appendImage(image)
                    }

                    group.leave()
                }
            }
        }

        for asset in assets {
            loadImage(from: asset)
        }

        group.notify(queue: .main) {
            self.recentScreenshots = images
        }
    }
}

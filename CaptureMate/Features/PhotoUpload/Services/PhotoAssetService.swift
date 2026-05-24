//
//  PhotoAssetService.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation
import Photos

final class PhotoAssetService {
    func fetchScreenshotAssets() -> [PHAsset] {
        let options = PHFetchOptions()

        options.predicate = NSPredicate(
            format: "mediaSubtype & %d != 0",
            PHAssetMediaSubtype.photoScreenshot.rawValue
        )

        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let result = PHAsset.fetchAssets(
            with: .image,
            options: options
        )

        var assets: [PHAsset] = []

        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }

        return assets
    }

    func getImageData(from asset: PHAsset) async -> Data? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestImageDataAndOrientation(
                for: asset,
                options: options
            ) { data, _, _, _ in
                continuation.resume(returning: data)
            }
        }
    }
}

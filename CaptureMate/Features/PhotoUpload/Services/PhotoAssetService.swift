//
//  PhotoAssetService.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation
import UIKit
import Photos

final class PhotoAssetService {
    func fetchScreenshotAssets(from startDate: Date?) -> [PHAsset] {
        let options = PHFetchOptions()

        if let startDate {
            options.predicate = NSPredicate(
                format: "mediaSubtype & %d != 0 AND creationDate >= %@",
                PHAssetMediaSubtype.photoScreenshot.rawValue,
                startDate as NSDate
            )
        } else {
            options.predicate = NSPredicate(
                format: "mediaSubtype & %d != 0",
                PHAssetMediaSubtype.photoScreenshot.rawValue
            )
        }

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
    
    func getUIImage(from asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

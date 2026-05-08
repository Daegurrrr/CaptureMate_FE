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
    @Published var showDateFilterSheet = false

    private let lastCheckedDateKey = "lastCheckedScreenshotDate"
    private let screenshotStartDateKey = "screenshotStartDate"

    func requestPhotoPermissionAndLoad() {

        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        if currentStatus == .authorized || currentStatus == .limited {

            authorizationStatus = currentStatus
            handleAuthorizedState()
            return
        }

        if currentStatus == .notDetermined {

            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in

                Task { @MainActor in

                    self?.authorizationStatus = status

                    if status == .authorized || status == .limited {
                        self?.handleAuthorizedState()
                    }
                }
            }

        } else {

            authorizationStatus = currentStatus
        }
    }

    private func handleAuthorizedState() {

        if getSavedStartDate() == nil {

            showDateFilterSheet = true

        } else if let startDate = getSavedStartDate() {

            fetchScreenshots(from: startDate)
        }
    }

    func selectStartDate(_ startDate: Date) {

        UserDefaults.standard.set(
            startDate,
            forKey: screenshotStartDateKey
        )

        NotificationCenter.default.post(
            name: NSNotification.Name("ScreenshotDataUpdated"),
            object: nil
        )

        fetchScreenshots(from: startDate)
    }

    private func getSavedStartDate() -> Date? {

        UserDefaults.standard.object(
            forKey: screenshotStartDateKey
        ) as? Date
    }

    private func fetchScreenshots(from startDate: Date) {

        isLoading = true

        let lastCheckedDate = UserDefaults.standard.object(
            forKey: lastCheckedDateKey
        ) as? Date

        let fetchOptions = PHFetchOptions()

        fetchOptions.sortDescriptors = [
            NSSortDescriptor(
                key: "creationDate",
                ascending: false
            )
        ]


        // =====================================================
        // MARK: 시뮬레이터용
        // =====================================================

//        fetchOptions.predicate = NSPredicate(
//            format: "creationDate >= %@",
//            startDate as NSDate
//        )


        // =====================================================
        // MARK: 실제 아이폰용
        // =====================================================
        
         fetchOptions.predicate = NSPredicate(
             format: "creationDate >= %@ AND (mediaSubtype & %d) != 0",
             startDate as NSDate,
             PHAssetMediaSubtype.photoScreenshot.rawValue
         )
        
        // =====================================================

        fetchOptions.fetchLimit = 50

        let assets = PHAsset.fetchAssets(
            with: .image,
            options: fetchOptions
        )

        var newAssets: [PHAsset] = []
        var existingAssets: [PHAsset] = []

        assets.enumerateObjects { asset, _, _ in


            // =================================================
            // MARK: 실제 아이폰용
            // =================================================
            
             guard asset.mediaSubtypes.contains(.photoScreenshot)
             else {
                 return
             }
            
            // =================================================


            if let lastCheckedDate,
               let creationDate = asset.creationDate,
               creationDate > lastCheckedDate {

                newAssets.append(asset)

            } else {

                existingAssets.append(asset)
            }
        }

        loadImages(
            newAssets: newAssets,
            existingAssets: existingAssets,
            isFirstLoad: lastCheckedDate == nil
        )
    }

    
//    private func loadImages(
//        newAssets: [PHAsset],
//        existingAssets: [PHAsset],
//        isFirstLoad: Bool
//    ) {
//        let imageManager = PHCachingImageManager()
//        let targetSize = CGSize(width: 300, height: 300)
//
//        var loadedNewPhotos: [ScreenshotPhoto] = []
//        var loadedExistingPhotos: [ScreenshotPhoto] = []
//
//        let group = DispatchGroup()
//
//        func appendPhoto(_ image: UIImage, asset: PHAsset, isNew: Bool) {
//            let photo = ScreenshotPhoto(
//                id: asset.localIdentifier,
//                asset: asset,
//                image: image
//            )
//
//            if isNew {
//                loadedNewPhotos.append(photo)
//            } else {
//                loadedExistingPhotos.append(photo)
//            }
//        }
//
//        func loadImage(from asset: PHAsset, isNew: Bool) {
//            group.enter()
//
//            let dataOptions = PHImageRequestOptions()
//            dataOptions.isSynchronous = false
//            dataOptions.deliveryMode = .highQualityFormat
//            dataOptions.resizeMode = .none
//            dataOptions.isNetworkAccessAllowed = true
//
//            imageManager.requestImageDataAndOrientation(
//                for: asset,
//                options: dataOptions
//            ) { data, _, _, info in
//
//                if let data, let image = UIImage(data: data) {
//                    appendPhoto(image, asset: asset, isNew: isNew)
//                    group.leave()
//                    return
//                }
//
//                let thumbOptions = PHImageRequestOptions()
//                thumbOptions.isSynchronous = false
//                thumbOptions.deliveryMode = .opportunistic
//                thumbOptions.resizeMode = .fast
//                thumbOptions.isNetworkAccessAllowed = true
//
//                imageManager.requestImage(
//                    for: asset,
//                    targetSize: targetSize,
//                    contentMode: .aspectFill,
//                    options: thumbOptions
//                ) { image, info in
//                    let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
//
//                    if isDegraded {
//                        return
//                    }
//
//                    if let image {
//                        appendPhoto(image, asset: asset, isNew: isNew)
//                    } else if let error = info?[PHImageErrorKey] as? Error {
//                        print("Fallback image request error:", error.localizedDescription)
//                    }
//
//                    group.leave()
//                }
//            }
//        }
//
//        for asset in newAssets {
//            loadImage(from: asset, isNew: true)
//        }
//
//        for asset in existingAssets {
//            loadImage(from: asset, isNew: false)
//        }
//
//        group.notify(queue: .main) {
//            if isFirstLoad {
//                self.newScreenshots = []
//                self.allScreenshots = loadedExistingPhotos
//            } else {
//                self.newScreenshots = loadedNewPhotos
//                self.allScreenshots = loadedNewPhotos + loadedExistingPhotos
//            }
//
//            self.isLoading = false
//
//            UserDefaults.standard.set(
//                Date(),
//                forKey: self.lastCheckedDateKey
//            )
//
//            NotificationCenter.default.post(
//                name: NSNotification.Name("ScreenshotDataUpdated"),
//                object: nil
//            )
//        }
//    }
    
    private func loadImages(
        newAssets: [PHAsset],
        existingAssets: [PHAsset],
        isFirstLoad: Bool
    ) {

        let imageManager = PHCachingImageManager()

        let targetSize = CGSize(
            width: 300,
            height: 300
        )

        var loadedNewPhotos: [ScreenshotPhoto] = []
        var loadedExistingPhotos: [ScreenshotPhoto] = []

        let group = DispatchGroup()

        let requestOptions = PHImageRequestOptions()

        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .fastFormat
        requestOptions.resizeMode = .fast


        // =====================================================
        // MARK: 실제 아이폰 + iCloud용
        // =====================================================
        
         requestOptions.deliveryMode = .opportunistic
         requestOptions.isNetworkAccessAllowed = true
        
        // =====================================================

        func requestImage(
            from asset: PHAsset,
            isNew: Bool
        ) {

            group.enter()

            var didFinish = false

            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, info in

                let isDegraded =
                    info?[PHImageResultIsDegradedKey] as? Bool ?? false

                if isDegraded {
                    return
                }

                guard !didFinish else {
                    return
                }

                didFinish = true

                if let image {

                    let photo = ScreenshotPhoto(
                        id: asset.localIdentifier,
                        asset: asset,
                        image: image
                    )

                    if isNew {

                        loadedNewPhotos.append(photo)

                    } else {

                        loadedExistingPhotos.append(photo)
                    }
                }

                group.leave()
            }
        }

        for asset in newAssets {

            requestImage(
                from: asset,
                isNew: true
            )
        }

        for asset in existingAssets {

            requestImage(
                from: asset,
                isNew: false
            )
        }

        group.notify(queue: .main) {

            if isFirstLoad {

                self.newScreenshots = []

                self.allScreenshots =
                    loadedExistingPhotos

            } else {

                self.newScreenshots =
                    loadedNewPhotos

                self.allScreenshots =
                    loadedNewPhotos + loadedExistingPhotos
            }

            self.isLoading = false

            UserDefaults.standard.set(
                Date(),
                forKey: self.lastCheckedDateKey
            )

            NotificationCenter.default.post(
                name: NSNotification.Name("ScreenshotDataUpdated"),
                object: nil
            )
        }
    }
}

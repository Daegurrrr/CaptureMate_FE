//
//  PhotoLibraryObserver.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/24/26.
//

import Foundation
import Photos
import SwiftData

@MainActor
final class PhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {
    private let photoUploadService = PhotoUploadService()
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()

        PHPhotoLibrary.shared().register(self)

        print("PhotoLibraryObserver 등록 완료")
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)

        print("PhotoLibraryObserver 해제")
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("사진 라이브러리 변경 감지")

        Task { @MainActor in
            await photoUploadService.uploadNewPhotos(
                modelContext: modelContext
            )
        }
    }
}

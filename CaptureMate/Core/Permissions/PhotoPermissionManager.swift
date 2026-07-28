//
//  PhotoPermissionManager.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/12/26.
//

import Photos

final class PhotoPermissionManager {

    static let shared = PhotoPermissionManager()

    private init() {}

    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch currentStatus {
        case .authorized, .limited:
            completion(true)

        case .notDetermined, .denied, .restricted:
            completion(false)

        @unknown default:
            completion(false)
        }
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch currentStatus {
        case .authorized, .limited:
            completion(true)

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    completion(status == .authorized || status == .limited)
                }
            }

        case .denied, .restricted:
            completion(false)

        @unknown default:
            completion(false)
        }
    }
}

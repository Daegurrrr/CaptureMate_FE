//
//  PermissionSettingViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 6/11/26.
//

import SwiftUI
import Photos

@MainActor
final class PermissionSettingViewModel: ObservableObject {
    @Published var photoStatus: PHAuthorizationStatus = .notDetermined

    func checkPhotoPermission() {
        photoStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    var photoStatusText: String {
        switch photoStatus {
        case .authorized:
            return "전체 사진 접근 허용"
        case .limited:
            return "선택한 사진만 접근 허용"
        case .denied:
            return "사진 접근 거부됨"
        case .restricted:
            return "사진 접근 제한됨"
        case .notDetermined:
            return "아직 권한을 요청하지 않음"
        @unknown default:
            return "권한 상태 확인 불가"
        }
    }

    var isPhotoPermissionAllowed: Bool {
        photoStatus == .authorized || photoStatus == .limited
    }
}

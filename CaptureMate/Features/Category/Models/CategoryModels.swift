//
//  CategoryModels.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

struct CategoryCaptureItem: Identifiable {
    let id = UUID()
    let imageName: String
    let category: CaptureCategory
}

// 분류 모델돌리기 전 그냥 사진 보여주기 위한 코드
import UIKit

struct CategoryPhotoItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

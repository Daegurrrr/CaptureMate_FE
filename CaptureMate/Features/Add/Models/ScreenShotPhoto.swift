//
//  ScreenShotPhoto.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/8/26.
//

import UIKit
import Photos

struct ScreenshotPhoto: Identifiable {
    let id: String
    let asset: PHAsset
    let image: UIImage
}

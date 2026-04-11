//
//  ScreenshotItem.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import Foundation

struct ScreenshotItem: Identifiable, Hashable {

    let id = UUID()

    let title: String
    let subtitle: String

    let category: CaptureCategory

    // OCR에서 추출된 텍스트
    let extractedText: String

}

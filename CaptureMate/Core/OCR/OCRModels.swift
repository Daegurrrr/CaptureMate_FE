//
//  OCRModels.swift
//  CaptureMate
//
//  Created by Codex on 7/29/26.
//

import CoreGraphics
import Foundation

enum OCRTextTier {
    case title
    case body
    case caption
    case noise
}

struct OCRItem {
    let text: String
    let confidence: Double
    let box: [CGPoint]
    let tier: OCRTextTier
}

struct PaddleOCRPage {
    let texts: [String]
    let scores: [Double]
    let boxes: [[CGPoint]]
}

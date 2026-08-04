//
//  VisionOCREngine.swift
//  CaptureMate
//
//  Created by Codex on 7/29/26.
//

import CoreGraphics
import Foundation
import UIKit
import Vision

final class VisionOCREngine {
    func recognize(imageData: Data) async throws -> [OCRItem] {
        try await Task.detached(priority: .userInitiated) {
            guard let image = UIImage(data: imageData),
                  let cgImage = image.cgImage else {
                return []
            }

            let imageSize = CGSize(
                width: cgImage.width,
                height: cgImage.height
            )

            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ko-KR", "en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: CGImagePropertyOrientation(image.imageOrientation),
                options: [:]
            )

            try handler.perform([request])

            let observations = request.results ?? []

            return observations.compactMap { observation -> OCRItem? in
                guard let candidate = observation.topCandidates(1).first else {
                    return nil
                }

                let text = OCRTextPreprocessor.normalizeLine(candidate.string)

                guard !text.isEmpty else {
                    return nil
                }

                let rect = Self.convertVisionBoundingBox(
                    observation.boundingBox,
                    imageSize: imageSize
                )

                let box = [
                    CGPoint(x: rect.minX, y: rect.minY),
                    CGPoint(x: rect.maxX, y: rect.minY),
                    CGPoint(x: rect.maxX, y: rect.maxY),
                    CGPoint(x: rect.minX, y: rect.maxY)
                ]

                return OCRItem(
                    text: text,
                    confidence: Double(candidate.confidence),
                    box: box,
                    tier: OCRLayoutProcessor.classifyTextTier(
                        box: box,
                        imageHeight: imageSize.height
                    )
                )
            }
        }.value
    }

    private static func convertVisionBoundingBox(
        _ boundingBox: CGRect,
        imageSize: CGSize
    ) -> CGRect {
        CGRect(
            x: boundingBox.minX * imageSize.width,
            y: (1 - boundingBox.maxY) * imageSize.height,
            width: boundingBox.width * imageSize.width,
            height: boundingBox.height * imageSize.height
        )
    }
}

private extension CGImagePropertyOrientation {
    init(_ imageOrientation: UIImage.Orientation) {
        switch imageOrientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left:
            self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}

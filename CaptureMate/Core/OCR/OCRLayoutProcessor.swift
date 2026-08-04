//
//  OCRLayoutProcessor.swift
//  CaptureMate
//
//  Created by Codex on 7/29/26.
//

import CoreGraphics
import Foundation

enum OCRLayoutProcessor {
    static func classifyTextTier(
        box: [CGPoint],
        imageHeight: CGFloat
    ) -> OCRTextTier {
        guard imageHeight > 0 else {
            return .body
        }

        let ratio = textHeight(box: box) / imageHeight

        if ratio >= 0.040 {
            return .title
        } else if ratio >= 0.020 {
            return .body
        } else if ratio >= 0.016 {
            return .caption
        } else {
            return .noise
        }
    }

    static func centerY(box: [CGPoint]) -> CGFloat {
        guard let minY = box.map(\.y).min(),
              let maxY = box.map(\.y).max() else {
            return 0
        }

        return (minY + maxY) / 2
    }

    static func textHeight(box: [CGPoint]) -> CGFloat {
        guard let minY = box.map(\.y).min(),
              let maxY = box.map(\.y).max() else {
            return 0
        }

        return maxY - minY
    }

    static func intersectionOverUnion(
        _ firstBox: [CGPoint],
        _ secondBox: [CGPoint]
    ) -> CGFloat {
        let firstRect = boundingRect(for: firstBox)
        let secondRect = boundingRect(for: secondBox)
        let intersection = firstRect.intersection(secondRect)

        if intersection.isNull || intersection.isEmpty {
            return 0
        }

        let intersectionArea = intersection.width * intersection.height
        let unionArea = firstRect.width * firstRect.height
            + secondRect.width * secondRect.height
            - intersectionArea

        return unionArea > 0 ? intersectionArea / unionArea : 0
    }

    static func removeDuplicateBoxes(
        from items: [OCRItem],
        threshold: CGFloat = 0.4
    ) -> [OCRItem] {
        let sortedItems = items.sorted { $0.confidence > $1.confidence }
        var kept: [OCRItem] = []

        for item in sortedItems {
            let hasOverlap = kept.contains {
                intersectionOverUnion(item.box, $0.box) >= threshold
            }

            if !hasOverlap {
                kept.append(item)
            }
        }

        return kept
    }

    static func groupLinesByY(
        items: [OCRItem],
        yGapThreshold: CGFloat = 18.0
    ) -> [String] {
        guard !items.isEmpty else {
            return []
        }

        let sortedItems = items.sorted {
            centerY(box: $0.box) < centerY(box: $1.box)
        }

        var groups: [[OCRItem]] = []
        var currentGroup = [sortedItems[0]]

        for item in sortedItems.dropFirst() {
            let previousY = centerY(box: currentGroup.last?.box ?? [])
            let currentY = centerY(box: item.box)

            if abs(currentY - previousY) <= yGapThreshold {
                currentGroup.append(item)
            } else {
                groups.append(currentGroup)
                currentGroup = [item]
            }
        }

        groups.append(currentGroup)

        return groups.compactMap { group in
            let line = group
                .sorted { ($0.box.first?.x ?? 0) < ($1.box.first?.x ?? 0) }
                .map(\.text)
                .joined(separator: " ")

            let normalizedLine = OCRTextPreprocessor.normalizeLine(line)
            return normalizedLine.isEmpty ? nil : normalizedLine
        }
    }

    private static func boundingRect(for box: [CGPoint]) -> CGRect {
        guard let minX = box.map(\.x).min(),
              let maxX = box.map(\.x).max(),
              let minY = box.map(\.y).min(),
              let maxY = box.map(\.y).max() else {
            return .zero
        }

        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
}

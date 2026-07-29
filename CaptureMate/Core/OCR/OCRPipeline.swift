//
//  OCRPipeline.swift
//  CaptureMate
//
//  Created by Codex on 7/29/26.
//

import CoreGraphics
import Foundation

enum OCRPipeline {
    static func buildClassificationText(
        from page: PaddleOCRPage,
        imageHeight: CGFloat
    ) -> String {
        var items: [OCRItem] = []

        for index in page.texts.indices {
            guard index < page.scores.count,
                  index < page.boxes.count else {
                continue
            }

            let text = OCRTextPreprocessor.normalizeLine(page.texts[index])

            guard !text.isEmpty else {
                continue
            }

            let box = page.boxes[index]
            let tier = OCRLayoutProcessor.classifyTextTier(
                box: box,
                imageHeight: imageHeight
            )

            items.append(
                OCRItem(
                    text: text,
                    confidence: page.scores[index],
                    box: box,
                    tier: tier
                )
            )
        }

        let dedupedItems = OCRLayoutProcessor.removeDuplicateBoxes(from: items)
        let filteredItems = dedupedItems.filter(OCRTextFilter.shouldKeepForClassification)
        let rawLines = OCRLayoutProcessor.groupLinesByY(items: filteredItems)
        let cleanedLines = rawLines.filter { line in
            let value = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if OCRTextFilter.isStatusBarText(value) {
                return false
            }

            if value.matches(pattern: #"^\d{1,4}$"#) {
                return false
            }

            if value.matches(pattern: #"^\d{1,2}:\d{2}$"#) {
                return false
            }

            return true
        }

        return OCRTextBuilder.buildClassificationText(from: cleanedLines)
    }
}

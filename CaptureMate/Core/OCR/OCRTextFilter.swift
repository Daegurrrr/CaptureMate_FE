//
//  OCRTextFilter.swift
//  CaptureMate
//
//  Created by Codex on 7/29/26.
//

import Foundation

enum OCRTextFilter {
    static func shouldKeepForClassification(_ item: OCRItem) -> Bool {
        let text = item.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            return false
        }

        if isStatusBarText(text) {
            return false
        }

        if isUIText(text) {
            return false
        }

        if isNoiseToken(text) {
            return false
        }

        let hasImportantPattern = OCRTextPreprocessor.hasImportantPattern(text)

        switch item.tier {
        case .title:
            return item.confidence >= 0.50 || hasImportantPattern
        case .body:
            return item.confidence >= 0.45 || hasImportantPattern
        case .caption:
            return item.confidence >= 0.55 || hasImportantPattern
        case .noise:
            return item.confidence >= 0.65 || hasImportantPattern
        }
    }

    static func isStatusBarText(_ text: String) -> Bool {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let patterns = [
            #"^\d{1,2}:\d{2}$"#,
            #"^\d{1,3}%$"#,
            #"^(SKT|KT|LG U\+|5G|LTE)$"#,
            #"^오전\s*\d{1,2}:\d{2}$"#,
            #"^오후\s*\d{1,2}:\d{2}$"#,
            #"^[lI1]\s*5G$"#,
            #"^[lI1]\s*LTE$"#,
            #"^\d{1,2}:\d{2}\s*\d*\s*(SKT|KT|LG U\+|5G|LTE)?$"#
        ]

        return patterns.contains { value.matches(pattern: $0, options: [.caseInsensitive]) }
    }

    static func isUIText(_ text: String) -> Bool {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let exactMatches: Set<String> = [
            "대화를",
            "대화를 시작해보세요",
            "답글 1개 더 보기",
            "메뉴판 이미지로 보기",
            "정보 더보기",
            "답글 달기",
            "댓글",
            "Instagram"
        ]
        let containsMatches = [
            "대화를 시작해보세요",
            "답글 1개 더 보기",
            "메뉴판 이미지로 보기",
            "정보 더보기",
            "답글 달기"
        ]

        if exactMatches.contains(value) {
            return true
        }

        return containsMatches.contains { value.contains($0) }
    }

    static func isNoiseToken(_ text: String) -> Bool {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if value.isEmpty {
            return true
        }

        if OCRTextPreprocessor.hasImportantPattern(value) {
            return false
        }

        if value.matches(pattern: #"^[\W_]+$"#) {
            return true
        }

        if value.count == 1, !OCRTextPreprocessor.meaningfulSingleCharacters.contains(value) {
            return true
        }

        return false
    }
}

//
//  OCRTextPreprocessor.swift
//  CaptureMate
//
//  Created by Codex on 7/29/26.
//

import Foundation

enum OCRTextPreprocessor {
    static let importantPatterns = [
        #"\d{1,2}:\d{2}"#,
        #"\d{1,4}[./-]\d{1,2}([./-]\d{1,4})?"#,
        #"\d[\d,]*원"#,
        #"\d+\s*%"#,
        #"\d+\s*박"#,
        #"\d+\s*일"#,
        #"\d{2,4}-\d{3,4}-\d{4}"#,
        #"http[s]?://"#,
        #"www\."#,
        #"naver\.me"#,
        #"map\.naver"#,
        #"booking\.naver"#
    ]

    static let meaningfulSingleCharacters: Set<String> = [
        "%",
        "층",
        "원",
        "시",
        "분",
        "월",
        "일",
        "박"
    ]

    static func hasImportantPattern(_ text: String) -> Bool {
        importantPatterns.contains { text.matches(pattern: $0, options: [.caseInsensitive]) }
    }

    static func normalizeLine(_ text: String) -> String {
        var value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        value = value.replacing(pattern: #"[ \t]+"#, with: " ")
        value = value.replacing(pattern: #"\.{2,}"#, with: ".")
        value = value.replacing(pattern: #"\!{2,}"#, with: "!")
        value = value.replacing(pattern: #"\?{2,}"#, with: "?")
        value = value.replacing(pattern: #"\-{2,}"#, with: "-")
        value = value.replacing(pattern: #"\|{2,}"#, with: "|")

        value = normalizePrice(value)
        value = fixDateOCRErrors(value)

        value = value.replacing(pattern: #"\b[lI1]\s*5G\b"#, with: "5G", options: [.caseInsensitive])
        value = value.replacing(pattern: #"\b[lI1]\s*LTE\b"#, with: "LTE", options: [.caseInsensitive])
        value = value.replacing(pattern: #"\blLTE\b"#, with: "LTE", options: [.caseInsensitive])

        value = value.replacing(
            pattern: #"[^\w\s\.\,\/\-\:\~\(\)원%+#@&!]"#,
            with: ""
        )

        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizePrice(_ text: String) -> String {
        var value = text
        value = value.replacing(pattern: #"[₩\\](?=\d)"#, with: "원")
        value = value.replacing(pattern: #"\bW(?=\d[\d,]*)"#, with: "원")
        value = value.replacing(pattern: #"원\s*(\d[\d,]*)"#, with: "$1원")
        return value
    }

    static func fixDateOCRErrors(_ text: String) -> String {
        let pattern = #"\d{1,4}[./\-]\d{1,2}[이일오O0ㅇlI\d]*(?:[./\-~]\d{1,2}[이일오O0ㅇlI\d]*)?"#
        return text.replacingMatches(pattern: pattern) { match in
            match
                .replacingOccurrences(of: "이", with: "0")
                .replacingOccurrences(of: "일", with: "1")
                .replacingOccurrences(of: "오", with: "5")
                .replacingOccurrences(of: "O", with: "0")
                .replacingOccurrences(of: "l", with: "1")
                .replacingOccurrences(of: "I", with: "1")
                .replacingOccurrences(of: "ㅇ", with: "0")
        }
    }
}

extension String {
    func matches(
        pattern: String,
        options: NSRegularExpression.Options = []
    ) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }

        let range = NSRange(startIndex..., in: self)
        return regex.firstMatch(in: self, range: range) != nil
    }

    func replacing(
        pattern: String,
        with replacement: String,
        options: NSRegularExpression.Options = []
    ) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return self
        }

        let range = NSRange(startIndex..., in: self)
        return regex.stringByReplacingMatches(
            in: self,
            range: range,
            withTemplate: replacement
        )
    }

    func replacingMatches(
        pattern: String,
        transform: (String) -> String
    ) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return self
        }

        let nsString = self as NSString
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
        var result = self

        for match in matches.reversed() {
            let value = nsString.substring(with: match.range)
            guard let range = Range(match.range, in: result) else {
                continue
            }

            result.replaceSubrange(range, with: transform(value))
        }

        return result
    }
}

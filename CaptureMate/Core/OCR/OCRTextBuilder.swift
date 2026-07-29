//
//  OCRTextBuilder.swift
//  CaptureMate
//
//  Created by Codex on 7/29/26.
//

import Foundation

enum OCRTextBuilder {
    static func buildClassificationText(from lines: [String]) -> String {
        let dedupedLines = dedupeShortLines(dedupeLines(lines))
        let text = dedupedLines.joined(separator: "\n")

        return text
            .replacing(pattern: #"\n{2,}"#, with: "\n")
            .replacing(pattern: #"[ \t]+"#, with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func dedupeLines(_ lines: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for line in lines {
            let key = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty, !seen.contains(key) else {
                continue
            }

            seen.insert(key)
            result.append(line)
        }

        return result
    }

    static func dedupeShortLines(_ lines: [String]) -> [String] {
        var counter: [String: Int] = [:]
        var result: [String] = []

        for line in lines {
            let key = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let wordCount = key.split(separator: " ").count

            if wordCount <= 2 {
                if (counter[key] ?? 0) >= 1 {
                    continue
                }

                counter[key, default: 0] += 1
            }

            result.append(line)
        }

        return result
    }
}

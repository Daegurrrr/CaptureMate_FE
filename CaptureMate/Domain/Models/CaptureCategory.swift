//
//  CaptureCategory.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

enum CaptureCategory: String, CaseIterable, Identifiable, Hashable {
    case schedule
    case place
    case shopping
    case memo
    case unknown

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .schedule: return "일정"
        case .place: return "장소"
        case .shopping: return "쇼핑"
        case .memo: return "메모"
        case .unknown: return "기타"
        }
    }

    var icon: String {
        switch self {
        case .schedule: return "calendar"
        case .place: return "mappin.and.ellipse"
        case .shopping: return "cart"
        case .memo: return "note.text"
        case .unknown: return "questionmark"
        }
    }

    var tint: Color {
        switch self {
        case .schedule: return .purple
        case .place: return .blue
        case .shopping: return .orange
        case .memo: return .green
        case .unknown: return .gray
        }
    }
}

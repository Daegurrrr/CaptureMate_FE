//
//  CaptureCategory.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

enum CaptureCategory: String, CaseIterable, Identifiable, Hashable {

    case place
    case discount
    case schedule
    case memo
    case coupon
    case unknown

    var id: String { rawValue }

    var displayTitle: String {

        switch self {

        case .place:
            return "장소"

        case .discount:
            return "할인"

        case .schedule:
            return "일정"

        case .memo:
            return "메모"

        case .coupon:
            return "쿠폰"
            
        case .unknown:
            return "기타"

        }

    }

    var icon: String {

        switch self {

        case .place:
            return "mappin.and.ellipse"

        case .discount:
            return "tag"

        case .schedule:
            return "calendar"

        case .memo:
            return "note.text"

        case .coupon:
            return "ticket"
            
        case .unknown:
            return "questionmark"

        }

    }

    var tint: Color {

        switch self {

        case .place:
            return .blue

        case .discount:
            return .orange

        case .schedule:
            return .purple

        case .memo:
            return .green

        case .coupon:
            return .pink

        case .unknown:
            return .gray
            
        
        }

    }

}

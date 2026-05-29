//
//  HomeModels.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import Foundation

struct CaptureSummary {
    let totalCount: Int
    let placeCount: Int
    let couponCount: Int
    let otherCount: Int
}

struct RecommendedAction: Identifiable {
    let id = UUID()

    let icon: String
    let title: String
    let subtitle: String?

    let type: ActionType
    let url: String?
    let dateText: String?
}

enum ActionType {
    case place
    case shopping
    case schedule
}

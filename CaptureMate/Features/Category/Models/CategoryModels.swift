//
//  CategoryModels.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation
import SwiftUI
import Photos

struct CategoryCaptureItem: Identifiable {
    let id = UUID()
    let imageName: String
    let category: CaptureCategory
}

struct CategoryPhotoItem: Identifiable {
    let id: String
    let image: UIImage
    let category: String
}
 
struct DetailDisplayItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let urlString: String?
}

struct PlaceItem: Decodable {
    let placeName: String?
    let address: String?
    let mapURL: String?
    let latitude: Double?
    let longitude: Double?

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case address
        case mapURL = "map_url"
        case latitude
        case longitude
    }
}

struct ShoppingItem: Decodable {
    let productName: String?
    let shoppingURL: String?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case shoppingURL = "shopping_url"
    }
}

struct ScheduleItem: Decodable {
    let title: String?
    let startAt: String?
    let endAt: String?

    enum CodingKeys: String, CodingKey {
        case title
        case startAt = "start_at"
        case endAt = "end_at"
    }
}

struct MemoItem: Decodable {
    let title: String?
    let content: String?
}

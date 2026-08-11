//
//  GeminiResponse.swift
//  CaptureMate
//
//  Created by Codex on 8/4/26.
//

import Foundation

struct GeminiResponse: Decodable {
    let localIdentifier: String
    let category: String
    let result: GeminiAnalysisResult

    enum CodingKeys: String, CodingKey, CaseIterable {
        case localIdentifier = "local_identifier"
        case category
        case result
    }
}

struct GeminiAnalysisResult: Decodable {
    let items: [ScreenshotSummaryItem]?
    let title: String?
    let content: String?
    let additionalFields: [String: JSONValue]

    enum CodingKeys: String, CodingKey, CaseIterable {
        case items
        case title
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent(
            [ScreenshotSummaryItem].self,
            forKey: .items
        )
        title = try container.decodeIfPresent(String.self, forKey: .title)
        content = try container.decodeIfPresent(String.self, forKey: .content)

        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
        let knownKeys = Set(CodingKeys.allCases.map(\.stringValue))

        additionalFields = dynamicContainer.allKeys.reduce(into: [:]) { fields, key in
            guard !knownKeys.contains(key.stringValue),
                  let value = try? dynamicContainer.decode(
                    JSONValue.self,
                    forKey: key
                  ) else {
                return
            }

            fields[key.stringValue] = value
        }
    }
}

struct ScreenshotSummaryItem: Decodable {
    let placeName: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let mapUrl: String?
    let mapProvider: String?

    let title: String?
    let startAt: String?
    let endAt: String?

    let productName: String?
    let shoppingUrl: String?
    let brandSearchUrl: String?

    let content: String?
    let additionalFields: [String: JSONValue]

    enum CodingKeys: String, CodingKey, CaseIterable {
        case placeName = "place_name"
        case address
        case latitude
        case longitude
        case mapUrl = "map_url"
        case mapProvider = "map_provider"

        case title
        case startAt = "start_at"
        case endAt = "end_at"

        case productName = "product_name"
        case shoppingUrl = "shopping_url"
        case brandSearchUrl = "brand_search_url"

        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        placeName = try container.decodeIfPresent(String.self, forKey: .placeName)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        mapUrl = try container.decodeIfPresent(String.self, forKey: .mapUrl)
        mapProvider = try container.decodeIfPresent(String.self, forKey: .mapProvider)

        title = try container.decodeIfPresent(String.self, forKey: .title)
        startAt = try container.decodeIfPresent(String.self, forKey: .startAt)
        endAt = try container.decodeIfPresent(String.self, forKey: .endAt)

        productName = try container.decodeIfPresent(String.self, forKey: .productName)
        shoppingUrl = try container.decodeIfPresent(String.self, forKey: .shoppingUrl)
        brandSearchUrl = try container.decodeIfPresent(String.self, forKey: .brandSearchUrl)

        content = try container.decodeIfPresent(String.self, forKey: .content)

        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
        let knownKeys = Set(CodingKeys.allCases.map(\.stringValue))

        additionalFields = dynamicContainer.allKeys.reduce(into: [:]) { fields, key in
            guard !knownKeys.contains(key.stringValue),
                  let value = try? dynamicContainer.decode(
                    JSONValue.self,
                    forKey: key
                  ) else {
                return
            }

            fields[key.stringValue] = value
        }
    }
}

enum JSONValue: Decodable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            self = .object(try container.decode([String: JSONValue].self))
        }
    }

    var displayText: String? {
        switch self {
        case .string(let value):
            return value.isEmpty ? nil : value
        case .number(let value):
            if value.rounded() == value {
                return String(Int(value))
            }
            return String(value)
        case .bool(let value):
            return value ? "true" : "false"
        case .array(let values):
            let text = values.compactMap(\.displayText).joined(separator: ", ")
            return text.isEmpty ? nil : text
        case .object(let object):
            let text = object
                .sorted { $0.key < $1.key }
                .compactMap { key, value -> String? in
                    guard let displayText = value.displayText else {
                        return nil
                    }
                    return "\(key): \(displayText)"
                }
                .joined(separator: ", ")
            return text.isEmpty ? nil : text
        case .null:
            return nil
        }
    }
}

struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}

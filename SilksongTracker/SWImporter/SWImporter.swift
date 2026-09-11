//
//  SWImporter.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/8/26.
//

import Foundation

enum SWImportError: LocalizedError {
    case missingUrl
}

enum SWImporter {
    static func importMapData() -> Result<SWMapData, Error> {
        guard let url = Bundle.main.url(forResource: "scripterswar_map_data_extracted", withExtension: "json") else {
            return  .failure(SWImportError.missingUrl)
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let mapData = try decoder.decode(SWMapData.self, from: data)
            return .success(mapData)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - Import from scripterswar data
struct SWMapData: Codable {
    let name: String
    let id: String
    let interactiveMap: SWInteractiveMap
    let categories: [SWCategory]
}

struct SWInteractiveMap: Codable {
    let mapLinks: SWMapLinks
}

struct SWMapLinks: Codable {
    let smallGaps: [SWMapConnection]
    let largeGapsConnectingOverVoid: [SWMapConnection]
    let largeGapsConnectingOverMaps: [SWMapConnection]
}

struct SWMapConnection: Codable {
    let start: SWPosition
    let end: SWPosition

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let start = try container.decode(SWPosition.self)
        let end = try container.decode(SWPosition.self)

        if !container.isAtEnd {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected line pair to contain exactly two values."
            )
        }

        self.start = start
        self.end = end
    }
}

struct SWCategory: Codable {
    let id: MarkerCategory
    let name: String
    let list: [SWCategoryItem]
}

struct SWCategoryItem: Codable {
    let name: String
    let uid: Int?
    let iconUrl: String?
    let pos: SWPosition
    let pos2: SWPosition?
    let tags: [String]?

    var position: SWPosition { pos2 ?? pos }
}

struct SWPosition: Codable {
    let lat: CGFloat
    let lng: CGFloat

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()

        let lat = try container.decode(Double.self)
        let lng = try container.decode(Double.self)

        if !container.isAtEnd {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected point pair to contain exactly two values."
            )
        }

        self.lat = lat
        self.lng = lng
    }
}

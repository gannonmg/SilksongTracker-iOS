//
//  MapData.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/8/26.
//

import Foundation

enum MapDataFactory {
    static func buildMapData(from scriptersData: SWMapData) -> MapData {
        var maxUid = 0
        var unidentifiedItems: [MarkerCategory: [SWCategoryItem]] = [:]
        var markers: [MarkerCategory: [MarkerItem]] = [:]

        // Store categories with canonical UIDs
        for category in scriptersData.categories {
            for item in category.list {
                if let uid = item.uid {
                    maxUid = max(uid, maxUid)
                    let markerItem = MarkerItem(id: uid, item: item, category: category.id)
                    markers[category.id, default: []].append(markerItem)
                } else {
                    unidentifiedItems[category.id, default: []].append(item)
                }
            }
        }

        // For items with missing UID, artificially create one for our app based on the highest we saw from scripterswar
        for (category, items) in unidentifiedItems {
            for item in items {
                maxUid += 1
                let markerItem = MarkerItem(id: maxUid, item: item, category: category)
                markers[category, default: []].append(markerItem)
            }
        }

        return MapData(markers: markers)
    }
}

struct MapData: Codable {
    let markers: [MarkerCategory: [MarkerItem]]
}

struct MarkerItem: Codable, Identifiable {
    let id: Int
    let location: CGPoint
    let name: String
    let iconName: String
    let group: MarkerCategoryGroup
    let category: MarkerCategory
    let act: Act

    init(id: Int, item: SWCategoryItem, category: MarkerCategory) {
        self.id = id
        let location = CGPoint(x: item.position.lng / 2048,
                               y: abs(item.position.lat) / 2048)
        self.location = location
        self.name = item.name
        let group = category.group
        self.iconName = if let iconUrl = item.iconUrl, !iconUrl.isEmpty {
            iconUrl.replacing(".png", with: "")
        } else {
            group.defaultIconName
        }
        self.group = group
        self.category = category
        self.act = min(category.minimumAct, Act(from: item.tags))
    }
}

// MARK: - Acts
enum Act: String, Comparable, Codable {
    case act1, act2, act3

    private var actNumber: Int {
        switch self {
        case .act1: 1
        case .act2: 2
        case .act3: 3
        }
    }

    var label: String { "Act \(actNumber)" }

    static func < (lhs: borrowing Act, rhs: borrowing Act) -> Bool {
        lhs.actNumber < rhs.actNumber
    }

    init(from tags: [String]?) {
        let taggedAct = tags?.compactMap { Act(rawValue: $0) }.first
        self = taggedAct ?? .act1
    }
}

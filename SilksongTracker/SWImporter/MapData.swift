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
                    maxUid = max(maxUid, maxUid)
                    let markerItem = MarkerItem(id: uid, item: item, group: category.id.group)
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
                let markerItem = MarkerItem(id: maxUid, item: item, group: category.group)
                markers[category, default: []].append(markerItem)
            }
        }

        let allItems = markers.values.flatMap { $0.map(\.self) }
        let maxX = allItems.map(\.location.x).max()
        let minX = allItems.map(\.location.x).min()
        let maxY = allItems.map(\.location.y).max()
        let minY = allItems.map(\.location.y).min()
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

    init(id: Int, item: SWCategoryItem, group: MarkerCategoryGroup) {
        self.id = id
        let location = CGPoint(x: item.position.lng / 2048,
                               y: abs(item.position.lat) / 2048)
        self.location = location
        self.name = item.name
        self.iconName = item.iconUrl?.replacing(".png", with: "") ?? group.defaultIconName
        self.group = group
    }
}

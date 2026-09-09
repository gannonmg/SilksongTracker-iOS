//
//  MapDataViewModel.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/8/26.
//

import CoreGraphics
import Foundation
import Observation

@MainActor
@Observable
final class MapDataViewModel {
    let mapData: MapData

    private(set) var enabledCategories = Set(MarkerCategory.allCases)
    private let spatialIndexes: [MarkerCategory: MarkerSpatialIndex]

    init(mapData: MapData) {
        self.mapData = mapData
        self.spatialIndexes = mapData.markers.mapValues {
            MarkerSpatialIndex(markers: $0)
        }
    }

    func visibleItems(
        in viewport: CGRect,
        contentSize: CGSize
    ) -> [MarkerItem] {
        guard contentSize.width > 0, contentSize.height > 0 else {
            return []
        }

        let bufferedViewport = TileSet.bufferedVisibleRect(
            from: viewport,
            contentSize: contentSize
        )

        guard !bufferedViewport.isNull, !bufferedViewport.isEmpty else {
            return []
        }

        let normalizedViewport = CGRect(
            x: bufferedViewport.minX / contentSize.width,
            y: bufferedViewport.minY / contentSize.height,
            width: bufferedViewport.width / contentSize.width,
            height: bufferedViewport.height / contentSize.height
        )

        return MarkerCategory.allCases.flatMap { (category) -> [MarkerItem] in
            guard enabledCategories.contains(category) else {
                return []
            }

            return spatialIndexes[category]?
                .markers(in: normalizedViewport) ?? []
        }
    }
}

extension CGPoint {
    static func * (lhs: Self, scale: CGFloat) -> Self {
        CGPoint(x: lhs.x * scale, y: lhs.y * scale)
    }
}

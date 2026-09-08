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
    private(set) var enabledCategories: Set<MarkerCategory> = Set(MarkerCategory.allCases)

    init(mapData: MapData) {
        self.mapData = mapData
    }

    private func enabledCategoryItems() -> [MarkerItem] {
        enabledCategories.flatMap { mapData.markers[$0, default: []] }
    }

    func visibleItems(
        in viewport: CGRect,
        at resolution: TileResolutionLevel,
        contentSize: CGSize
    ) -> [MarkerItem] {
        let bufferedViewport = TileSet.bufferedVisibleRect(from: viewport, contentSize: contentSize)
        let items = enabledCategoryItems()
            .filter { item in
                let location = item.location * contentSize.width
                return bufferedViewport.contains(location)
            }
        return items
    }
}

extension CGPoint {
    static func * (lhs: Self, scale: CGFloat) -> Self {
        CGPoint(x: lhs.x * scale, y: lhs.y * scale)
    }
}

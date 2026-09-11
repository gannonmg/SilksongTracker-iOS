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
    private let mapData: MapData

    private(set) var enabledCategories: Set<MarkerCategory>
    private(set) var clusters: [MarkerCluster]

    private var clusteringScale: CGFloat
    private let spatialIndexes: [MarkerCategory: MarkerSpatialIndex]
    private let clusterer: MarkerClusterer

    init(mapData: MapData) {
        let enabledCategories = Set(MarkerCategory.allCases)
        let clusterer = MarkerClusterer()

        self.mapData = mapData
        self.enabledCategories = enabledCategories
        self.clusteringScale = 1
        self.spatialIndexes = mapData.markers.mapValues {
            MarkerSpatialIndex(markers: $0)
        }
        self.clusterer = clusterer
        self.clusters = clusterer.clusters(
            in: mapData.markers,
            enabledCategories: enabledCategories,
            displayScale: 1
        )
    }

    func spoilerFilteredItems() -> [MarkerCategory: [MarkerItem]] {
        // TODO: Store and reference the user's current Act
        let currentAct = Act.act1
        var filteredCategories: [MarkerCategory: [MarkerItem]] = [:]
        for (category, items) in mapData.markers {
            let filteredItems = items.filter { $0.act <= currentAct }
            guard !filteredItems.isEmpty else { continue }
            filteredCategories[category] = filteredItems
        }
        return filteredCategories
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
            guard enabledCategories.contains(category) else { return [] }
            return spatialIndexes[category]?.markers(in: normalizedViewport) ?? []
        }
    }

    func visibleClusters(
        in viewport: CGRect,
        contentSize: CGSize
    ) -> [MarkerCluster] {
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

        return clusters.filter {
            normalizedViewport.contains($0.location)
        }
    }

    func updateClusters(for displayScale: CGFloat) {
        guard displayScale > 0 else {
            return
        }

        let scaleDifference = abs(displayScale - clusteringScale)
        guard scaleDifference
                >= MarkerDisplayConfiguration.clusterScaleChangeThreshold
        else {
            return
        }

        let step = MarkerDisplayConfiguration.clusterScaleStep
        let nextScale = max(
            step,
            (displayScale / step).rounded() * step
        )

        guard nextScale != clusteringScale else {
            return
        }

        clusteringScale = nextScale
        rebuildClusters()
    }

    func setCategory(_ category: MarkerCategory, isEnabled: Bool) {
        if isEnabled {
            enabledCategories.insert(category)
        } else {
            enabledCategories.remove(category)
        }

        rebuildClusters()
    }

    private func rebuildClusters() {
        clusters = clusterer.clusters(
            in: mapData.markers,
            enabledCategories: enabledCategories,
            displayScale: clusteringScale
        )
    }
}

extension CGPoint {
    static func * (lhs: Self, scale: CGFloat) -> Self {
        CGPoint(x: lhs.x * scale, y: lhs.y * scale)
    }
}

//
//  MarkerCluster.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/9/26.
//

import CoreGraphics

struct MarkerCluster: Identifiable {
    let id: [MarkerItem.ID]
    let members: [MarkerItem]
    let location: CGPoint
    let representative: MarkerItem
}

struct MarkerClusterer {
    private struct Entry {
        let marker: MarkerItem
        let category: MarkerCategory
    }

    private let screenDistance: CGFloat

    init(screenDistance: CGFloat = 36) {
        precondition(screenDistance > 0)
        self.screenDistance = screenDistance
    }

    func clusters(
        in markersByCategory: [MarkerCategory: [MarkerItem]],
        enabledCategories: Set<MarkerCategory>,
        displayScale: CGFloat
    ) -> [MarkerCluster] {
        guard displayScale > 0 else {
            return []
        }

        let entries = MarkerCategory.allCases
            .filter(enabledCategories.contains)
            .flatMap { category in
                markersByCategory[category, default: []].map {
                    Entry(marker: $0, category: category)
                }
            }
            .sorted { $0.marker.id < $1.marker.id }

        let markers = entries.map(\.marker)
        let categoriesByID = Dictionary(
            uniqueKeysWithValues: entries.map {
                ($0.marker.id, $0.category)
            }
        )

        let spatialIndex = MarkerSpatialIndex(markers: markers)
        let normalizedDistance =
            screenDistance / (Constants.tileSideLength * displayScale)
        let maximumDistanceSquared =
            normalizedDistance * normalizedDistance

        var assignedIDs: Set<MarkerItem.ID> = []
        var clusters: [MarkerCluster] = []

        for seed in markers where !assignedIDs.contains(seed.id) {
            let searchRect = CGRect(
                x: seed.location.x - normalizedDistance,
                y: seed.location.y - normalizedDistance,
                width: normalizedDistance * 2,
                height: normalizedDistance * 2
            )

            let members = spatialIndex.markers(in: searchRect)
                .filter {
                    !assignedIDs.contains($0.id)
                    && Self.distanceSquared(
                        from: seed.location,
                        to: $0.location
                    ) <= maximumDistanceSquared
                }
                .sorted { $0.id < $1.id }

            guard !members.isEmpty else {
                continue
            }

            assignedIDs.formUnion(members.map(\.id))

            let location = Self.centroid(of: members)
            guard let representative = members.min(by: { lhs, rhs in
                let lhsPriority =
                    categoriesByID[lhs.id]?.clusterPriority ?? 1
                let rhsPriority =
                    categoriesByID[rhs.id]?.clusterPriority ?? 1

                if lhsPriority != rhsPriority {
                    return lhsPriority > rhsPriority
                }

                let lhsDistance = Self.distanceSquared(
                    from: lhs.location,
                    to: location
                )
                let rhsDistance = Self.distanceSquared(
                    from: rhs.location,
                    to: location
                )

                if lhsDistance != rhsDistance {
                    return lhsDistance < rhsDistance
                }

                return lhs.id < rhs.id
            }) else {
                continue
            }

            clusters.append(
                MarkerCluster(
                    id: members.map(\.id),
                    members: members,
                    location: location,
                    representative: representative
                )
            )
        }

        return clusters
    }

    private static func centroid(
        of markers: [MarkerItem]
    ) -> CGPoint {
        let total = markers.reduce(into: CGPoint.zero) { result, marker in
            result.x += marker.location.x
            result.y += marker.location.y
        }
        let count = CGFloat(markers.count)

        return CGPoint(
            x: total.x / count,
            y: total.y / count
        )
    }

    private static func distanceSquared(
        from lhs: CGPoint,
        to rhs: CGPoint
    ) -> CGFloat {
        let xDistance = lhs.x - rhs.x
        let yDistance = lhs.y - rhs.y
        return xDistance * xDistance + yDistance * yDistance
    }
}

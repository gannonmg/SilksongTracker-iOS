//
//  MarkerCluster.swift
//  SilksongTracker
//

import CoreGraphics

enum MarkerDisplayConfiguration {
    /// Marker artwork occupies a 24-point square before the map applies its live zoom transform.
    static let iconLength: CGFloat = 24

    /// Adds breathing room around neighboring marker artwork and its count badge.
    static let desiredClusterSpacing: CGFloat = 12

    /// Centers closer than the icon length plus its desired spacing are clustered.
    static let screenClusterDistance =
        iconLength + desiredClusterSpacing

    /// Cluster membership changes at whole-number effective zoom levels.
    static let clusterScaleStep: CGFloat = 1

    /// Extends the normal half-step boundary to prevent repeated changes near a threshold.
    static let clusterScaleHysteresis: CGFloat = 0.1

    static let clusterScaleChangeThreshold =
        clusterScaleStep / 2 + clusterScaleHysteresis
}

/// A renderable group of nearby markers positioned at their shared centroid.
struct MarkerCluster: Identifiable {
    /// Member IDs form stable cluster identity until membership changes.
    let id: [MarkerItem.ID]
    let members: [MarkerItem]
    let location: CGPoint
    let representative: MarkerItem
}

/// Creates deterministic, non-transitive marker clusters at the current display scale.
struct MarkerClusterer {
    private struct Entry {
        let marker: MarkerItem
        let category: MarkerCategory
    }

    func clusters(
        in markersByCategory: [MarkerCategory: [MarkerItem]],
        enabledCategories: Set<MarkerCategory>,
        displayScale: CGFloat
    ) -> [MarkerCluster] {
        guard displayScale > 0 else {
            return []
        }

        // Preserve category information for priority selection, then sort by stable
        // identity so dictionary and source ordering cannot change cluster membership.
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

        // Marker locations use normalized 0...1 map coordinates. Dividing the
        // desired screen distance by the rendered map length converts it into
        // the normalized radius required by the spatial index.
        let normalizedDistance =
            MarkerDisplayConfiguration.screenClusterDistance
            / (Constants.tileSideLength * displayScale)
        let maximumDistanceSquared =
            normalizedDistance * normalizedDistance

        var assignedIDs: Set<MarkerItem.ID> = []
        var clusters: [MarkerCluster] = []

        // Each unassigned marker anchors one cluster. Members are assigned once,
        // preventing overlapping clusters and preventing proximity chains from
        // combining markers that are far apart overall.
        for seed in markers where !assignedIDs.contains(seed.id) {
            let searchRect = CGRect(
                x: seed.location.x - normalizedDistance,
                y: seed.location.y - normalizedDistance,
                width: normalizedDistance * 2,
                height: normalizedDistance * 2
            )

            // The index efficiently supplies candidates from the surrounding
            // square. The distance check then enforces the intended circular
            // proximity boundary.
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

            // The centroid provides a neutral render position rather than
            // visually favoring whichever member happened to seed the cluster.
            let location = Self.centroid(of: members)

            guard let representative = Self.representative(
                among: members,
                categoriesByID: categoriesByID,
                clusterLocation: location
            ) else {
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

    /// Averages member locations to find the cluster’s normalized map position.
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

    /// Prefers category priority, then centrality, then stable identity.
    private static func representative(
        among markers: [MarkerItem],
        categoriesByID: [MarkerItem.ID: MarkerCategory],
        clusterLocation: CGPoint
    ) -> MarkerItem? {
        markers.min { lhs, rhs in
            let lhsPriority =
                categoriesByID[lhs.id]?.clusterPriority ?? 1
            let rhsPriority =
                categoriesByID[rhs.id]?.clusterPriority ?? 1

            if lhsPriority != rhsPriority {
                return lhsPriority > rhsPriority
            }

            let lhsDistance = distanceSquared(
                from: lhs.location,
                to: clusterLocation
            )
            let rhsDistance = distanceSquared(
                from: rhs.location,
                to: clusterLocation
            )

            if lhsDistance != rhsDistance {
                return lhsDistance < rhsDistance
            }

            return lhs.id < rhs.id
        }
    }

    /// Compares proximity without performing an unnecessary square root.
    private static func distanceSquared(
        from lhs: CGPoint,
        to rhs: CGPoint
    ) -> CGFloat {
        let xDistance = lhs.x - rhs.x
        let yDistance = lhs.y - rhs.y
        return xDistance * xDistance + yDistance * yDistance
    }
}

//
//  MarkerSpatialIndex.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/8/26.
//

import CoreGraphics

/// A sparse uniform-grid index for querying markers in normalized map coordinates.
/// Queries inspect only intersecting buckets, then apply exact point containment.
struct MarkerSpatialIndex {
    private struct Cell: Hashable {
        let column: Int
        let row: Int
    }

    private let cellCount: Int
    private let buckets: [Cell: [MarkerItem]]

    /// Divides each normalized axis into `cellCount` buckets.
    /// Bucket count affects lookup granularity, not marker coordinate precision.
    init(markers: [MarkerItem], cellCount: Int = 64) {
        precondition(cellCount > 0)

        self.cellCount = cellCount
        self.buckets = Dictionary(grouping: markers) { marker in
            Self.cell(
                containing: marker.location,
                cellCount: cellCount
            )
        }
    }

    /// Returns markers inside the query’s intersection with the normalized unit map.
    /// Bucket lookup narrows candidates; the rectangle check determines inclusion.
    func markers(in normalizedRect: CGRect) -> [MarkerItem] {
        let mapBounds = CGRect(
            origin: .zero,
            size: CGSize(width: 1, height: 1)
        )
        let queryRect = normalizedRect.intersection(mapBounds)

        guard !queryRect.isNull, !queryRect.isEmpty else {
            return []
        }

        let lowerCell = Self.cell(
            containing: CGPoint(x: queryRect.minX, y: queryRect.minY),
            cellCount: cellCount
        )
        let upperCell = Self.cell(
            containing: CGPoint(x: queryRect.maxX, y: queryRect.maxY),
            cellCount: cellCount
        )

        var result: [MarkerItem] = []

        for row in lowerCell.row...upperCell.row {
            for column in lowerCell.column...upperCell.column {
                let cell = Cell(column: column, row: row)

                guard let markers = buckets[cell] else {
                    continue
                }

                for marker in markers where queryRect.contains(marker.location) {
                    result.append(marker)
                }
            }
        }

        return result
    }

    private static func cell(
        containing point: CGPoint,
        cellCount: Int
    ) -> Cell {
        Cell(
            column: coordinate(for: point.x, cellCount: cellCount),
            row: coordinate(for: point.y, cellCount: cellCount)
        )
    }

    /// Clamps boundary and outlying values so they always map to a valid cell.
    private static func coordinate(
        for value: CGFloat,
        cellCount: Int
    ) -> Int {
        min(
            cellCount - 1,
            max(0, Int(floor(value * CGFloat(cellCount))))
        )
    }
}

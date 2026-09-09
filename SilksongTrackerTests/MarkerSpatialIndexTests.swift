//
//  MarkerSpatialIndexTests.swift
//  SilksongTracker
//
//  Created by Matt Gannon on 9/9/26.
//

import CoreGraphics
import Foundation
import Testing
@testable import SilksongTracker

struct MarkerSpatialIndexTests {
    // Verifies that buckets supply candidates while exact rectangle containment filters results.
    @Test
    func queryReturnsOnlyMarkersInsideRectangle() throws {
        let index = MarkerSpatialIndex(
            markers: [
                try marker(id: 1, location: CGPoint(x: 0.10, y: 0.10)),
                try marker(id: 2, location: CGPoint(x: 0.24, y: 0.24)),
                try marker(id: 3, location: CGPoint(x: 0.26, y: 0.24)),
                try marker(id: 4, location: CGPoint(x: 0.75, y: 0.75))
            ],
            cellCount: 4
        )

        let markers = index.markers(
            in: CGRect(x: 0, y: 0, width: 0.25, height: 0.25)
        )

        #expect(markers.map(\.id).sorted() == [1, 2])
    }

    // Verifies that a query crossing a bucket boundary searches cells on both sides.
    @Test
    func querySearchesAcrossCellBoundaries() throws {
        let index = MarkerSpatialIndex(
            markers: [
                try marker(id: 1, location: CGPoint(x: 0.24, y: 0.24)),
                try marker(id: 2, location: CGPoint(x: 0.26, y: 0.24)),
                try marker(id: 3, location: CGPoint(x: 0.75, y: 0.75))
            ],
            cellCount: 4
        )

        let markers = index.markers(
            in: CGRect(x: 0.23, y: 0.20, width: 0.04, height: 0.10)
        )

        #expect(markers.map(\.id).sorted() == [1, 2])
    }

    // Verifies that overscanning is clipped to the unit map and disjoint queries return nothing.
    @Test
    func queryIsClippedToNormalizedMapBounds() throws {
        let index = MarkerSpatialIndex(
            markers: [
                try marker(id: 1, location: CGPoint(x: 0.05, y: 0.05)),
                try marker(id: 2, location: CGPoint(x: 0.95, y: 0.95))
            ],
            cellCount: 4
        )

        let partiallyIntersecting = index.markers(
            in: CGRect(x: -0.10, y: -0.10, width: 0.20, height: 0.20)
        )
        let nonintersecting = index.markers(
            in: CGRect(x: 2, y: 2, width: 1, height: 1)
        )

        #expect(partiallyIntersecting.map(\.id) == [1])
        #expect(nonintersecting.isEmpty)
    }

    // Verifies the integration of viewport buffering, coordinate normalization, and invalid-size handling.
    @Test
    @MainActor
    func viewModelNormalizesAndBuffersViewport() throws {
        let mapData = MapData(
            markers: [
                .benches: [
                    try marker(id: 1, location: CGPoint(x: 0.20, y: 0.20)),
                    try marker(id: 2, location: CGPoint(x: 0.50, y: 0.50)),
                    try marker(id: 3, location: CGPoint(x: 0.80, y: 0.80))
                ]
            ]
        )
        let viewModel = MapDataViewModel(mapData: mapData)
        let contentSize = CGSize(width: 1_024, height: 1_024)

        // The 128-point buffer expands this viewport to normalized 0.25...0.75.
        let visibleMarkers = viewModel.visibleItems(
            in: CGRect(x: 384, y: 384, width: 256, height: 256),
            contentSize: contentSize
        )

        #expect(visibleMarkers.map(\.id) == [2])

        let initialMarkers = viewModel.visibleItems(
            in: .zero,
            contentSize: contentSize
        )
        #expect(initialMarkers.map(\.id).sorted() == [1, 2, 3])

        let markersWithInvalidContentSize = viewModel.visibleItems(
            in: .zero,
            contentSize: .zero
        )
        #expect(markersWithInvalidContentSize.isEmpty)
    }

    /// Creates fixtures through `MarkerItem`’s decoding contract.
    private func marker(
        id: Int,
        location: CGPoint
    ) throws -> MarkerItem {
        let json = """
        {
          "id": \(id),
          "location": [\(location.x), \(location.y)],
          "name": "Marker \(id)",
          "iconName": "bench",
          "group": "benchTransport"
        }
        """

        return try JSONDecoder().decode(
            MarkerItem.self,
            from: Data(json.utf8)
        )
    }
}

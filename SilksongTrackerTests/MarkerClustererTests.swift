//
//  MarkerClustererTests.swift
//  SilksongTrackerTests
//

import CoreGraphics
import Foundation
import Testing
@testable import SilksongTracker

struct MarkerClustererTests {
    @Test
    func highestPriorityMarkerRepresentsCluster() throws {
        let shard = try marker(
            id: 1,
            location: CGPoint(x: 0.50, y: 0.50),
            category: .shard
        )
        let bench = try marker(
            id: 2,
            location: CGPoint(x: 0.51, y: 0.50),
            category: .benches
        )

        let clusters = MarkerClusterer().clusters(
            in: [
                .shard: [shard],
                .benches: [bench]
            ],
            enabledCategories: [.shard, .benches],
            displayScale: 1
        )

        #expect(clusters.count == 1)
        #expect(clusters[0].members.count == 2)
        #expect(clusters[0].representative.id == bench.id)
    }

    @Test
    func zoomSeparatesMarkers() throws {
        let first = try marker(
            id: 1,
            location: CGPoint(x: 0.50, y: 0.50),
            category: .boss
        )
        let second = try marker(
            id: 2,
            location: CGPoint(x: 0.52, y: 0.50),
            category: .boss
        )
        let markers: [MarkerCategory: [MarkerItem]] = [
            .boss: [first, second]
        ]

        let zoomedOut = MarkerClusterer().clusters(
            in: markers,
            enabledCategories: [.boss],
            displayScale: 1
        )
        let zoomedIn = MarkerClusterer().clusters(
            in: markers,
            enabledCategories: [.boss],
            displayScale: 2
        )

        #expect(zoomedOut.count == 1)
        #expect(zoomedIn.count == 2)
    }

    @Test
    func equalPriorityUsesLowestIDAtEqualDistance() throws {
        let first = try marker(
            id: 1,
            location: CGPoint(x: 0.49, y: 0.50),
            category: .boss
        )
        let second = try marker(
            id: 2,
            location: CGPoint(x: 0.51, y: 0.50),
            category: .ability
        )

        let clusters = MarkerClusterer().clusters(
            in: [
                .boss: [first],
                .ability: [second]
            ],
            enabledCategories: [.boss, .ability],
            displayScale: 1
        )

        #expect(clusters[0].representative.id == first.id)
    }

    @Test
    func resultDoesNotDependOnInputOrder() throws {
        let first = try marker(
            id: 1,
            location: CGPoint(x: 0.50, y: 0.50),
            category: .boss
        )
        let second = try marker(
            id: 2,
            location: CGPoint(x: 0.51, y: 0.50),
            category: .boss
        )

        let forward = MarkerClusterer().clusters(
            in: [.boss: [first, second]],
            enabledCategories: [.boss],
            displayScale: 1
        )
        let reversed = MarkerClusterer().clusters(
            in: [.boss: [second, first]],
            enabledCategories: [.boss],
            displayScale: 1
        )

        #expect(forward.map(\.id) == reversed.map(\.id))
        #expect(
            forward.map(\.representative.id)
                == reversed.map(\.representative.id)
        )
    }

    private func marker(
        id: Int,
        location: CGPoint,
        category: MarkerCategory
    ) throws -> MarkerItem {
        let json = """
        {
          "id": \(id),
          "location": [\(location.x), \(location.y)],
          "name": "Marker \(id)",
          "iconName": "\(category.group.defaultIconName)",
          "group": "\(category.group.rawValue)"
        }
        """

        return try JSONDecoder().decode(
            MarkerItem.self,
            from: Data(json.utf8)
        )
    }
}
